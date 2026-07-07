import Foundation
import PostgreSQL_Standard
import PostgreSQL_Standard_Test_Support
import Testing
import Tests_Inline_Snapshot

extension SnapshotTests {
    @Suite struct ValuesTests {
        @Test func basics() {
            assertInlineSnapshot(of: Values(1, "Hello", true), as: .sql) {
                """
                SELECT 1, 'Hello', true
                """
            }
        }

        @Test func union() {
            assertInlineSnapshot(
                of: Values(1, "Hello", true)
                    .union(Values(2, "Goodbye", false)),
                as: .sql
            ) {
                """
                SELECT 1, 'Hello', true
                  UNION
                SELECT 2, 'Goodbye', false
                """
            }
        }
    }
}
