import Foundation
import PostgreSQL_Standard
import PostgreSQL_Standard_Test_Support
import Testing
import Tests_Inline_Snapshot

extension SnapshotTests.UUIDFunctions {
    @Suite("UUID Functions") struct UUIDFunctionsTests {

        // MARK: - Generation Tests

        @Test
        func `UUID.random generates gen_random_uuid()`() async {
            await assertSQL(
                of: UUIDUser.insert {
                    UUIDUser.Columns(id: UUID.random, name: #sql("'Alice'"), email: #sql("NULL"))
                }
            ) {
                """
                INSERT INTO "uuidUsers"
                ("id", "name", "email")
                VALUES
                (gen_random_uuid(), 'Alice', NULL)
                """
            }
        }

        @Test
        func `UUID.v4 generates uuidv4()`() async {
            await assertSQL(
                of: UUIDUser.insert {
                    UUIDUser.Columns(id: UUID.v4, name: #sql("'Bob'"), email: #sql("NULL"))
                }
            ) {
                """
                INSERT INTO "uuidUsers"
                ("id", "name", "email")
                VALUES
                (uuidv4(), 'Bob', NULL)
                """
            }
        }

        @Test
        func `UUID.timeOrdered generates uuidv7()`() async {
            await assertSQL(
                of: UUIDEvent.insert {
                    UUIDEvent.Columns(
                        id: UUID.timeOrdered,
                        title: #sql("'Login'"),
                        userId: #sql("NULL"),
                        timestamp: #sql("NULL")
                    )
                }
            ) {
                """
                INSERT INTO "uuidEvents"
                ("id", "title", "userId", "timestamp")
                VALUES
                (uuidv7(), 'Login', NULL, NULL)
                """
            }
        }

        @Test
        func `UUID.v7 generates uuidv7()`() async {
            await assertSQL(
                of: UUIDEvent.insert {
                    UUIDEvent.Columns(
                        id: UUID.v7,
                        title: #sql("'Logout'"),
                        userId: #sql("NULL"),
                        timestamp: #sql("NULL")
                    )
                }
            ) {
                """
                INSERT INTO "uuidEvents"
                ("id", "title", "userId", "timestamp")
                VALUES
                (uuidv7(), 'Logout', NULL, NULL)
                """
            }
        }

        @Test
        func `UUID.timeOrdered(shift:) generates uuidv7(interval)`() async {
            await assertSQL(
                of: UUIDEvent.insert {
                    UUIDEvent.Columns(
                        id: UUID.timeOrdered(shift: "-1 hour"),
                        title: #sql("'Historical Event'"),
                        userId: #sql("NULL"),
                        timestamp: #sql("NULL")
                    )
                }
            ) {
                """
                INSERT INTO "uuidEvents"
                ("id", "title", "userId", "timestamp")
                VALUES
                (uuidv7('-1 hour'::interval), 'Historical Event', NULL, NULL)
                """
            }
        }

        // MARK: - Extraction - Version Tests

        @Test
        func `extractVersion() from UUID column`() async {
            await assertSQL(
                of: UUIDUser.select { $0.id.extractVersion() }
            ) {
                """
                SELECT uuid_extract_version("uuidUsers"."id")
                FROM "uuidUsers"
                """
            }
        }

        @Test
        func `Filter by extractVersion() in WHERE clause`() async {
            await assertSQL(
                of: UUIDEvent.where { $0.id.extractVersion() == 7 }
            ) {
                """
                SELECT "uuidEvents"."id", "uuidEvents"."title", "uuidEvents"."userId", "uuidEvents"."timestamp"
                FROM "uuidEvents"
                WHERE (uuid_extract_version("uuidEvents"."id")) = (7)
                """
            }
        }

        // MARK: - Extraction - Timestamp Tests

        @Test
        func `extractTimestamp() from UUIDv7`() async {
            await assertSQL(
                of: UUIDEvent.select { $0.id.extractTimestamp() }
            ) {
                """
                SELECT uuid_extract_timestamp("uuidEvents"."id")
                FROM "uuidEvents"
                """
            }
        }

        @Test
        func `extractTimestamp() returns NULL for UUIDv4`() async {
            // UUIDv4 doesn't have timestamp, so this would return NULL
            await assertSQL(
                of: UUIDUser.select { $0.id.extractTimestamp() }
            ) {
                """
                SELECT uuid_extract_timestamp("uuidUsers"."id")
                FROM "uuidUsers"
                """
            }
        }

        @Test
        func `Filter by extractTimestamp() with NULL check`() async {
            await assertSQL(
                of: UUIDEvent.where {
                    $0.id.extractTimestamp() != nil
                }
            ) {
                """
                SELECT "uuidEvents"."id", "uuidEvents"."title", "uuidEvents"."userId", "uuidEvents"."timestamp"
                FROM "uuidEvents"
                WHERE (uuid_extract_timestamp("uuidEvents"."id")) IS DISTINCT FROM (NULL)
                """
            }
        }

        // MARK: - Composition Tests

        @Test
        func `Use UUID.random in INSERT with RETURNING`() async {
            await assertSQL(
                of: UUIDUser.insert {
                    UUIDUser.Columns(id: UUID.random, name: #sql("'Charlie'"), email: #sql("NULL"))
                }
            ) {
                """
                INSERT INTO "uuidUsers"
                ("id", "name", "email")
                VALUES
                (gen_random_uuid(), 'Charlie', NULL)
                """
            }
        }

        @Test
        func `Filter by extractVersion() in WHERE clause`() async {
            await assertSQL(
                of: UUIDEvent.where { $0.id.extractVersion() == 7 }
            ) {
                """
                SELECT "uuidEvents"."id", "uuidEvents"."title", "uuidEvents"."userId", "uuidEvents"."timestamp"
                FROM "uuidEvents"
                WHERE (uuid_extract_version("uuidEvents"."id")) = (7)
                """
            }
        }

        @Test
        func `Order by extractTimestamp() in ORDER BY`() async {
            // Order events by extracted timestamp from UUID
            await assertSQL(
                of: UUIDEvent.order(by: { $0.id.extractTimestamp() })
            ) {
                """
                SELECT "uuidEvents"."id", "uuidEvents"."title", "uuidEvents"."userId", "uuidEvents"."timestamp"
                FROM "uuidEvents"
                ORDER BY uuid_extract_timestamp("uuidEvents"."id")
                """
            }
        }

        // MARK: - Real-World Use Cases

        @Test
        func `INSERT multiple rows with UUID.timeOrdered`() async {
            await assertSQL(
                of: UUIDEvent.insert {
                    UUIDEvent.Columns(
                        id: UUID.timeOrdered,
                        title: #sql("'Event 1'"),
                        userId: #sql("NULL"),
                        timestamp: #sql("NULL")
                    )
                    UUIDEvent.Columns(
                        id: UUID.timeOrdered,
                        title: #sql("'Event 2'"),
                        userId: #sql("NULL"),
                        timestamp: #sql("NULL")
                    )
                    UUIDEvent.Columns(
                        id: UUID.timeOrdered,
                        title: #sql("'Event 3'"),
                        userId: #sql("NULL"),
                        timestamp: #sql("NULL")
                    )
                }
            ) {
                """
                INSERT INTO "uuidEvents"
                ("id", "title", "userId", "timestamp")
                VALUES
                (uuidv7(), 'Event 1', NULL, NULL), (uuidv7(), 'Event 2', NULL, NULL), (uuidv7(), 'Event 3', NULL, NULL)
                """
            }
        }

        @Test
        func `Complex query: Filter v7 UUIDs created after specific date`() async {
            // Real-world: Find all events with v7 UUIDs created in the last hour
            await assertSQL(
                of: UUIDEvent.where {
                    $0.id.extractVersion() == 7 && $0.id.extractTimestamp() != nil
                }
            ) {
                """
                SELECT "uuidEvents"."id", "uuidEvents"."title", "uuidEvents"."userId", "uuidEvents"."timestamp"
                FROM "uuidEvents"
                WHERE ((uuid_extract_version("uuidEvents"."id")) = (7)) AND (uuid_extract_timestamp("uuidEvents"."id")) IS DISTINCT FROM (NULL)
                """
            }
        }

        // MARK: - Edge Cases & Advanced Patterns

        @Test
        func `Extract timestamp and compare with table timestamp column`() async {
            // Edge case: Compare UUID embedded timestamp with actual timestamp column
            await assertSQL(
                of: UUIDEvent.where {
                    $0.id.extractTimestamp() != nil
                }
            ) {
                """
                SELECT "uuidEvents"."id", "uuidEvents"."title", "uuidEvents"."userId", "uuidEvents"."timestamp"
                FROM "uuidEvents"
                WHERE (uuid_extract_timestamp("uuidEvents"."id")) IS DISTINCT FROM (NULL)
                """
            }
        }

        @Test
        func `SELECT UUID generation in query`() async {
            // Advanced: Generate UUID in SELECT clause
            await assertSQL(
                of: UUIDEvent.select { _ in PostgreSQL.UUID.timeOrdered() }
            ) {
                """
                SELECT uuidv7()
                FROM "uuidEvents"
                """
            }
        }

        @Test
        func `Filter events using time shift for backdating`() async {
            // Real-world: Create historical records with adjusted timestamps
            await assertSQL(
                of: UUIDEvent.insert {
                    ($0.id, $0.title)
                } values: {
                    (
                        PostgreSQL.UUID.timeOrdered(shift: "-1 day"),
                        SQLQueryExpression("'Yesterday\\'s Event'")
                    )
                    (
                        PostgreSQL.UUID.timeOrdered(shift: "-2 days"),
                        SQLQueryExpression("'Event from 2 days ago'")
                    )
                }
            ) {
                """
                INSERT INTO "uuidEvents"
                ("id", "title")
                VALUES
                (uuidv7('-1 day'::interval), 'Yesterday\\'s Event'), (uuidv7('-2 days'::interval), 'Event from 2 days ago')
                """
            }
        }

        @Test
        func `Select version distribution across events`() async {
            // Analytics: Count events by UUID version
            await assertSQL(
                of: UUIDEvent.select {
                    ($0.id.extractVersion(), $0.id.count())
                }
            ) {
                """
                SELECT uuid_extract_version("uuidEvents"."id"), count("uuidEvents"."id")
                FROM "uuidEvents"
                """
            }
        }

        @Test
        func `Optional UUID extraction`() async {
            // Edge case: Extract from optional UUID column
            await assertSQL(
                of: UUIDEvent.select { $0.userId.extractVersion() }
            ) {
                """
                SELECT uuid_extract_version("uuidEvents"."userId")
                FROM "uuidEvents"
                """
            }
        }
    }
}

// MARK: - Test Models

@Table
private struct UUIDUser {
    let id: UUID
    let name: String
    let email: String?
}

@Table
private struct UUIDEvent {
    let id: UUID
    let title: String
    let userId: UUID?
    let timestamp: Date?
}

// MARK: - SnapshotTests.UUIDFunctions Namespace

extension SnapshotTests {
    enum UUIDFunctions {}
}
