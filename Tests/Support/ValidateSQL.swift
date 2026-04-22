import Foundation
import Tests_Inline_Snapshot
import Structured_Queries_Primitives
import Testing

#if SQLValidation
    import Logging
    import NIOCore
    import NIOPosix
    import PostgresNIO
#endif

// MARK: - Shared Client
#if SQLValidation
    /// Global EventLoopGroup for all validation clients
    private let validationEventLoopGroup = MultiThreadedEventLoopGroup.singleton

    /// Shared PostgresClient for ALL SQL validations
    /// This prevents "too many connections" by reusing a single connection pool
    private actor SharedValidationClient {
        private var client: PostgresClient?
        private var runTask: Task<Void, Never>?
        private var connectionFailed = false

        func getOrCreateClient() async throws -> PostgresClient {
            // If we previously failed to connect, don't retry
            if connectionFailed {
                throw ValidationError.connectionUnavailable
            }

            if let existing = client {
                return existing
            }

            let config = try postgresConfiguration()

            // Use a quieter logger that doesn't log connection errors
            var logger = Logger(label: "sql-validation")
            logger.logLevel = .error  // Only log actual errors, not connection attempts

            let newClient = PostgresClient(
                configuration: config,
                eventLoopGroup: validationEventLoopGroup,
                backgroundLogger: logger
            )
            self.client = newClient

            // Start client.run() once for the shared client
            let task = Task {
                await newClient.run()
            }
            self.runTask = task

            // Register shutdown handler on first client creation
            if !shutdownHandlerRegistered {
                shutdownHandlerRegistered = true
                atexit {
                    let semaphore = DispatchSemaphore(value: 0)
                    Task {
                        await sharedValidationClient.shutdown()
                        semaphore.signal()
                    }
                    _ = semaphore.wait(timeout: .now() + .seconds(5))
                }
            }

            // Test connection with a quick query
            do {
                try await newClient.withConnection { connection in
                    _ = try await connection.query(
                        PostgresQuery(unsafeSQL: "SELECT 1"),
                        logger: logger
                    )
                }
            } catch {
                // Connection failed - mark it and clean up
                connectionFailed = true
                runTask?.cancel()
                client = nil
                runTask = nil
                throw ValidationError.connectionUnavailable
            }

            return newClient
        }

        func shutdown() async {
            // Cancel run task
            runTask?.cancel()

            // Wait for cancellation
            if let task = runTask {
                await task.value
            }

            // Shutdown EventLoopGroup
            try? await validationEventLoopGroup.shutdownGracefully()

            client = nil
            runTask = nil
        }
    }

    private let sharedValidationClient = SharedValidationClient()

    /// Register shutdown handler on first use
    private nonisolated(unsafe) var shutdownHandlerRegistered = false
#endif

// MARK: - SQL Validation

/// Validates that generated SQL is syntactically correct PostgreSQL and matches the expected snapshot.
///
/// ```swift
/// await assertSQL(of: Reminder.select(\.title)) {
///     """
///     SELECT "reminders"."title" FROM "reminders"
///     """
/// }
/// ```
///
/// - Parameters:
///   - statement: The statement to validate
///   - matches: The expected SQL output (optional - will be recorded if nil)
public func assertSQL<T>(
    of statement: some Statement<T>,
    matches: (() -> String)? = nil,
    fileID: String = #fileID,
    filePath: String = #filePath,
    function: String = #function,
    line: Int = #line,
    column: Int = #column
) async {
    // Snapshot the SQL
    await snapshot(
        as: .sql,
        { statement },
        matches: matches,
        fileID: fileID,
        filePath: filePath,
        line: line,
        column: column,
        function: function
    )
    #if SQLValidation
        // Then validate syntax against PostgreSQL (asynchronous)
        await validatePostgreSQLSyntax(
            statement,
            fileID: fileID,
            filePath: filePath,
            function: function,
            line: line,
            column: column
        )
    #endif
}

#if SQLValidation
    /// Validates SQL syntax against PostgreSQL without snapshotting.
    public func validatePostgreSQLSyntax<T>(
        _ statement: some Statement<T>,
        fileID: String = #fileID,
        filePath: String = #filePath,
        function: String = #function,
        line: Int = #line,
        column: Int = #column
    ) async {
        let sql = statement.query.debugDescription

        // Normalize whitespace to handle newlines and multiple spaces
        let normalizedSQL = sql.replacingOccurrences(
            of: "\\s+", with: " ", options: .regularExpression
        )
        .trimmingCharacters(in: .whitespaces)
        .uppercased()

        // Validate CREATE FUNCTION and CREATE TRIGGER using transaction rollback
        let ddlValidatablePrefixes = [
            "CREATE FUNCTION", "CREATE OR REPLACE FUNCTION", "CREATE TRIGGER",
        ]
        if ddlValidatablePrefixes.contains(where: { normalizedSQL.hasPrefix($0) }) {
            await validateDDLWithTransaction(
                sql,
                fileID: fileID,
                filePath: filePath,
                function: function,
                line: line,
                column: column
            )
            return
        }

        // Skip validation for other DDL that can't be validated
        let ddlSkippedPrefixes = [
            "CREATE VIEW", "CREATE TEMP VIEW", "CREATE TEMPORARY VIEW",
            "CREATE OR REPLACE VIEW", "CREATE OR REPLACE TEMP VIEW",
            "DROP VIEW", "CREATE TABLE", "DROP TABLE",
            "ALTER TABLE", "CREATE INDEX", "DROP INDEX",
            "DROP TRIGGER", "DROP FUNCTION",
        ]

        if ddlSkippedPrefixes.contains(where: { normalizedSQL.hasPrefix($0) }) {
            return
        }

        do {
            let client = try await sharedValidationClient.getOrCreateClient()

            do {
                var logger = Logger(label: "sql-validation")
                logger.logLevel = .error

                try await client.withConnection { connection in
                    let validationQuery = "EXPLAIN (FORMAT TEXT) \(sql)"
                    _ = try await connection.query(
                        PostgresQuery(unsafeSQL: validationQuery),
                        logger: logger
                    )
                }
            } catch {
                let errorString = String(reflecting: error)

                let isSyntaxError = errorString.contains("sqlState: 42601")
                let isSchemaError =
                    errorString.contains("sqlState: 42P01")
                    || errorString.contains("sqlState: 42703")
                    || errorString.contains("sqlState: 42883")

                if isSyntaxError {
                    Issue.record(
                        """
                        Invalid PostgreSQL SQL syntax:

                        \(sql)

                        Error: \(errorString)
                        """,
                        sourceLocation: SourceLocation(
                            fileID: fileID,
                            filePath: filePath,
                            line: line,
                            column: column
                        )
                    )
                } else if !isSchemaError {
                    Issue.record(
                        """
                        PostgreSQL validation error (might be OK if not a syntax error):

                        \(sql)

                        Error: \(errorString)
                        """,
                        sourceLocation: SourceLocation(
                            fileID: fileID,
                            filePath: filePath,
                            line: line,
                            column: column
                        )
                    )
                }
            }
        } catch let error as ValidationError where error == .connectionUnavailable {
            return
        } catch {
            return
        }
    }

    /// Validates DDL statements using transaction rollback.
    private func validateDDLWithTransaction(
        _ sql: String,
        fileID: String,
        filePath: String,
        function: String,
        line: Int,
        column: Int
    ) async {
        do {
            let client = try await sharedValidationClient.getOrCreateClient()

            var logger = Logger(label: "sql-validation")
            logger.logLevel = .error

            try await client.withConnection { connection in
                _ = try await connection.query(
                    PostgresQuery(unsafeSQL: "BEGIN"),
                    logger: logger
                )

                do {
                    _ = try await connection.query(
                        PostgresQuery(unsafeSQL: sql),
                        logger: logger
                    )

                    _ = try await connection.query(
                        PostgresQuery(unsafeSQL: "ROLLBACK"),
                        logger: logger
                    )
                } catch {
                    _ = try? await connection.query(
                        PostgresQuery(unsafeSQL: "ROLLBACK"),
                        logger: logger
                    )

                    let errorString = String(reflecting: error)

                    let isSyntaxError = errorString.contains("sqlState: 42601")
                    let isSchemaError =
                        errorString.contains("sqlState: 42P01")
                        || errorString.contains("sqlState: 42703")
                        || errorString.contains("sqlState: 42883")

                    if isSyntaxError {
                        Issue.record(
                            """
                            Invalid PostgreSQL DDL syntax:

                            \(sql)

                            Error: \(errorString)
                            """,
                            sourceLocation: SourceLocation(
                                fileID: fileID,
                                filePath: filePath,
                                line: line,
                                column: column
                            )
                        )
                    } else if !isSchemaError {
                        Issue.record(
                            """
                            PostgreSQL DDL validation error:

                            \(sql)

                            Error: \(errorString)
                            """,
                            sourceLocation: SourceLocation(
                                fileID: fileID,
                                filePath: filePath,
                                line: line,
                                column: column
                            )
                        )
                    }
                }
            }
        } catch let error as ValidationError where error == .connectionUnavailable {
            return
        } catch {
            return
        }
    }

    // MARK: - Configuration

    private func postgresConfiguration() throws -> PostgresClient.Configuration {
        if let urlString = ProcessInfo.processInfo.environment["POSTGRES_URL"] {
            guard let url = URL(string: urlString),
                let host = url.host(),
                let user = url.user
            else {
                throw ValidationError.invalidURL(urlString)
            }

            let database = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))

            return PostgresClient.Configuration(
                host: host,
                port: url.port ?? 5432,
                username: user,
                password: url.password,
                database: database.isEmpty ? nil : database,
                tls: .disable
            )
        }

        let host = ProcessInfo.processInfo.environment["POSTGRES_HOST"] ?? "localhost"
        let port = ProcessInfo.processInfo.environment["POSTGRES_PORT"].flatMap(Int.init) ?? 5432
        let username = ProcessInfo.processInfo.environment["POSTGRES_USER"] ?? "coenttb"
        let password = ProcessInfo.processInfo.environment["POSTGRES_PASSWORD"]
        let database = ProcessInfo.processInfo.environment["POSTGRES_DB"] ?? "test"

        return PostgresClient.Configuration(
            host: host,
            port: port,
            username: username,
            password: password?.isEmpty == true ? nil : password,
            database: database,
            tls: .disable
        )
    }

    private enum ValidationError: Swift.Error, Equatable {
        case invalidURL(String)
        case connectionUnavailable
    }

#endif
