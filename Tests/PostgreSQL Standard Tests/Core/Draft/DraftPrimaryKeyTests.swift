import Foundation
import PostgreSQL_Standard
import PostgreSQL_Standard_Test_Support
import Testing
import Tests_Inline_Snapshot

// Simple test table with UUID primary key
@Table("test_records")
struct SimpleRecord: Codable, Equatable, Identifiable {
    let id: UUID
    let name: String
    let value: Int
}

extension SnapshotTests {
    @Suite struct DraftPrimaryKeyTests {

        @Test func verifyDraftInsertSQL() {
            // Test that Draft with NULL id generates correct SQL
            let draft = SimpleRecord.Draft(
                name: "Test",
                value: 42
            )

            // This test verifies what SQL is actually generated
            // It should help us see if NULL is being included
            let insertStatement = SimpleRecord.insert { draft }

            // Print the actual SQL for debugging
            let query = insertStatement.query
            print("Generated SQL: \(query)")

            // Check if the SQL contains NULL (it shouldn't for PostgreSQL)
            // Convert to SQL string format
            let sql = "\(query)"
            #expect(!sql.contains("NULL"))
        }

        @Test func verifyDraftInsertWithConflict() {
            // Test Draft insert with ON CONFLICT
            let draft = SimpleRecord.Draft(
                name: "Test",
                value: 42
            )

            // This uses the new PrimaryKeyedTable.insert method we added
            let insertStatement = SimpleRecord.insert {
                draft
            } onConflict: { columns in
                // Trailing comma required: parameter-pack single-element tuple literal syntax
                // (TableColumn<Self, T1>, repeat TableColumn<Self, each T2>) with an empty pack.
                // swift-format requires no space before `)` here; SwiftLint's `comma` rule wants
                // one after — the two oracles disagree on this construct, so shield SwiftLint.
                // swiftlint:disable:next comma
                (columns.name,)
            } doUpdate: { row, excluded in
                row.value = excluded.value
            }

            // Print for debugging
            let conflictQuery = insertStatement.query
            print("Generated SQL with conflict: \(conflictQuery)")

            // With the current implementation, id column is included with DEFAULT
            // when there's any ON CONFLICT with NULL primary keys (conservative approach)
            let conflictSql = "\(conflictQuery)"
            #expect(conflictSql.contains("\"id\""))
            #expect(conflictSql.contains("DEFAULT"))
            #expect(!conflictSql.contains("NULL"))
        }

        @Test func verifyDirectDraftInsertSQL() async {
            // Regression (2026-07-13, production 23502): a direct `Draft.insert { draft }`
            // resolved to the generic `Table.insert` — Draft is a `TableDraft`, not a
            // `PrimaryKeyedTable`, so the NULL→DEFAULT overrides never fired and NULL was
            // bound into the primary-key slot. The `TableDraft` parity override must emit
            // DEFAULT instead.
            let draft = SimpleRecord.Draft(
                name: "Test",
                value: 42
            )

            await assertSQL(
                of: SimpleRecord.Draft.insert { draft }
            ) {
                """
                INSERT INTO "test_records"
                ("id", "name", "value")
                VALUES
                (DEFAULT, 'Test', 42)
                """
            }
        }

        @Test func verifyDirectDraftInsertWithExplicitId() {
            // Explicit primary keys pass through the TableDraft override untouched.
            let explicitId = UUID(uuidString: "123e4567-e89b-12d3-a456-426614174000")!
            let draft = SimpleRecord.Draft(
                id: explicitId,
                name: "Test",
                value: 42
            )

            let sql = "\(SimpleRecord.Draft.insert { draft }.query)"
            #expect(sql.contains("\"id\""))
            #expect(sql.contains("123e4567"))
            #expect(!sql.contains("DEFAULT"))
        }

        @Test func verifyDirectDraftInsertWithConflict() {
            // The conflict-target TableDraft override keeps the primary-key column with
            // DEFAULT so ON CONFLICT targeting the primary key remains valid.
            let draft = SimpleRecord.Draft(
                name: "Test",
                value: 42
            )

            let statement = SimpleRecord.Draft.insert {
                draft
            } onConflict: { columns in
                // swiftlint:disable:next comma
                (columns.name,)
            } doUpdate: { row, excluded in
                row.value = excluded.value
            }

            let sql = "\(statement.query)"
            #expect(sql.contains("\"id\""))
            #expect(sql.contains("DEFAULT"))
            #expect(!sql.contains("NULL"))
        }

        @Test func verifyExplicitIdDraft() {
            // Test Draft with explicit ID
            let explicitId = UUID(uuidString: "123e4567-e89b-12d3-a456-426614174000")!
            let draft = SimpleRecord.Draft(
                id: explicitId,
                name: "Test",
                value: 42
            )

            let insertStatement = SimpleRecord.insert { draft }

            let explicitQuery = insertStatement.query
            print("Generated SQL with explicit ID: \(explicitQuery)")

            // With explicit ID, the SQL should contain the "id" column
            let explicitSql = "\(explicitQuery)"
            #expect(explicitSql.contains("\"id\""))
            // And it should contain the UUID value, not NULL
            #expect(explicitSql.contains("123e4567"))
        }
    }
}
