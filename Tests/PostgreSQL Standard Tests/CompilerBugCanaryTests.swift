import Foundation
import PostgreSQL_Standard
import PostgreSQL_Standard_Macros
import PostgreSQL_Standard_Test_Support
import Testing
import Tests_Inline_Snapshot

extension SnapshotTests {
    @Suite(
        .disabled(
            "Compiler bug: Updates[dynamicMember:] with opaque types"
        )
    )
    struct CompilerBugCanaryTests {

        @Test func logicalNotWithUpdates() {
            assertInlineSnapshot(
                of: Reminder.update {
                    $0.isCompleted = !$0.isCompleted
                },
                as: .sql
            ) {
                """
                UPDATE "reminders"
                SET "isCompleted" = NOT ("reminders"."isCompleted")
                """
            }
        }

        @Test func comparisonWithUpdatesAndNil() {
            assertInlineSnapshot(
                of:
                    Reminder
                    .find(1)
                    .update {
                        $0.dueDate = Case()
                            .when($0.dueDate == nil, then: #sql("'2018-01-29 00:08:00.000'"))
                    }
                    .returning(\.dueDate),
                as: .sql
            ) {
                """
                UPDATE "reminders"
                SET "dueDate" = CASE WHEN ("reminders"."dueDate") IS NOT DISTINCT FROM (NULL) THEN '2018-01-29 00:08:00.000' END
                WHERE ("reminders"."id") IN ((1))
                RETURNING "dueDate"
                """
            }
        }

        @Test func updatesSubscriptWithSome() {
            assertInlineSnapshot(
                of: Reminder.update {
                    $0.title = "Test"
                    $0.isCompleted = true
                },
                as: .sql
            ) {
                """
                UPDATE "reminders"
                SET "title" = 'Test', "isCompleted" = true
                """
            }
        }

    }
}
