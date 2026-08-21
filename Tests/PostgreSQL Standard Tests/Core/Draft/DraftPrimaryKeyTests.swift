import Foundation
import PostgreSQL_Standard
import PostgreSQL_Standard_Macros
import PostgreSQL_Standard_Test_Support
import Testing
import Tests_Inline_Snapshot

@Table("test_records")
struct SimpleRecord: Codable, Equatable, Identifiable {
    let id: UUID
    let name: String
    let value: Int
}

extension SnapshotTests {
    @Suite struct DraftPrimaryKeyTests {

        @Test func verifyDraftInsertSQL() {

            let draft = SimpleRecord.Draft(
                name: "Test",
                value: 42
            )

            let insertStatement = SimpleRecord.insert { draft }

            let query = insertStatement.query
            print("Generated SQL: \(query)")

            let sql = "\(query)"
            #expect(!sql.contains("NULL"))
        }

        @Test func verifyDraftInsertWithConflict() {

            let draft = SimpleRecord.Draft(
                name: "Test",
                value: 42
            )

            let insertStatement = SimpleRecord.insert {
                draft
            } onConflict: { columns in

                (columns.name,)
            } doUpdate: { row, excluded in
                row.value = excluded.value
            }

            let conflictQuery = insertStatement.query
            print("Generated SQL with conflict: \(conflictQuery)")

            let conflictSql = "\(conflictQuery)"
            #expect(conflictSql.contains("\"id\""))
            #expect(conflictSql.contains("DEFAULT"))
            #expect(!conflictSql.contains("NULL"))
        }

        @Test func verifyDirectDraftInsertSQL() async {

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

            let draft = SimpleRecord.Draft(
                name: "Test",
                value: 42
            )

            let statement = SimpleRecord.Draft.insert {
                draft
            } onConflict: { columns in

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

            let explicitId = UUID(uuidString: "123e4567-e89b-12d3-a456-426614174000")!
            let draft = SimpleRecord.Draft(
                id: explicitId,
                name: "Test",
                value: 42
            )

            let insertStatement = SimpleRecord.insert { draft }

            let explicitQuery = insertStatement.query
            print("Generated SQL with explicit ID: \(explicitQuery)")

            let explicitSql = "\(explicitQuery)"
            #expect(explicitSql.contains("\"id\""))

            #expect(explicitSql.contains("123e4567"))
        }
    }
}
