import Foundation
import Tests_Inline_Snapshot
import PostgreSQL_Standard
import PostgreSQL_Standard_Test_Support
import Testing

extension SnapshotTests {
    @Suite struct EphemeralTests {
        @Test func basics() {
            assertInlineSnapshot(
                of: TestTable.select { $0.firstName + ", " + $0.lastName },
                as: .sql
            ) {
                """
                SELECT (("testTables"."firstName") || (', ')) || ("testTables"."lastName")
                FROM "testTables"
                """
            }
        }
    }
}

@Table private struct TestTable {
    var firstName = ""
    var lastName = ""
    @Ephemeral
    var displayName = ""
}
