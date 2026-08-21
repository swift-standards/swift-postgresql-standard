import Foundation
import PostgreSQL_Standard
import PostgreSQL_Standard_Test_Support
import Testing
import Tests_Inline_Snapshot

extension SnapshotTests.Commands.Select {
    @Suite struct WindowClauseTests {

        @Test func singleNamedWindow() async {
            await assertSQL(
                of: Reminder.all
                    .window("list_window") {
                        $0.partition(by: $1.remindersListID)
                            .order(by: $1.title.desc())
                    }
                    .select { ($0.title, rank().over("list_window")) }
            ) {
                """
                SELECT "reminders"."title", RANK() OVER list_window
                FROM "reminders"
                WINDOW list_window AS (PARTITION BY "reminders"."remindersListID" ORDER BY "reminders"."title" DESC)
                """
            }
        }

        @Test func multipleNamedWindows() async {
            await assertSQL(
                of: Reminder.all
                    .window("list_window") {
                        $0.partition(by: $1.remindersListID)
                            .order(by: $1.title.desc())
                    }
                    .window("overall_window") {
                        $0.order(by: $1.title.desc())
                    }
                    .select {
                        (
                            $0.title,
                            $0.remindersListID,
                            rank().over("list_window"),
                            rank().over("overall_window")
                        )
                    }
            ) {
                """
                SELECT "reminders"."title", "reminders"."remindersListID", RANK() OVER list_window, RANK() OVER overall_window
                FROM "reminders"
                WINDOW list_window AS (PARTITION BY "reminders"."remindersListID" ORDER BY "reminders"."title" DESC), overall_window AS (ORDER BY "reminders"."title" DESC)
                """
            }
        }

        @Test func mixedNamedAndInlineWindows() async {
            await assertSQL(
                of: Reminder.all
                    .window("list_window") {
                        $0.partition(by: $1.remindersListID)
                            .order(by: $1.title.desc())
                    }
                    .select {
                        let id = $0.id
                        return (
                            $0.title,
                            rank().over("list_window"),
                            rowNumber().over { $0.order(by: id) }
                        )
                    }
            ) {
                """
                SELECT "reminders"."title", RANK() OVER list_window, ROW_NUMBER() OVER (ORDER BY "reminders"."id")
                FROM "reminders"
                WINDOW list_window AS (PARTITION BY "reminders"."remindersListID" ORDER BY "reminders"."title" DESC)
                """
            }
        }

        @Test func noWindowClause() async {
            await assertSQL(
                of: Reminder.all
                    .select {
                        let listID = $0.remindersListID
                        let title = $0.title
                        return (
                            $0.title,
                            rank().over {
                                $0.partition(by: listID)
                                    .order(by: title.desc())
                            }
                        )
                    }
            ) {
                """
                SELECT "reminders"."title", RANK() OVER (PARTITION BY "reminders"."remindersListID" ORDER BY "reminders"."title" DESC)
                FROM "reminders"
                """
            }
        }

        @Test func namedWindowPartitionOnly() async {
            await assertSQL(
                of: Reminder.all
                    .window("list_window") {
                        $0.partition(by: $1.remindersListID)
                    }
                    .select { ($0.title, rowNumber().over("list_window")) }
            ) {
                """
                SELECT "reminders"."title", ROW_NUMBER() OVER list_window
                FROM "reminders"
                WINDOW list_window AS (PARTITION BY "reminders"."remindersListID")
                """
            }
        }

        @Test func namedWindowOrderOnly() async {
            await assertSQL(
                of: Reminder.all
                    .window("title_order") {
                        $0.order(by: $1.title.desc())
                    }
                    .select { ($0.title, rowNumber().over("title_order")) }
            ) {
                """
                SELECT "reminders"."title", ROW_NUMBER() OVER title_order
                FROM "reminders"
                WINDOW title_order AS (ORDER BY "reminders"."title" DESC)
                """
            }
        }

        @Test func reuseNamedWindow() async {
            await assertSQL(
                of: Reminder.all
                    .window("list_title") {
                        $0.partition(by: $1.remindersListID)
                            .order(by: $1.title.desc())
                    }
                    .select {
                        (
                            $0.title,
                            $0.remindersListID,
                            rank().over("list_title"),
                            denseRank().over("list_title"),
                            rowNumber().over("list_title")
                        )
                    }
            ) {
                """
                SELECT "reminders"."title", "reminders"."remindersListID", RANK() OVER list_title, DENSE_RANK() OVER list_title, ROW_NUMBER() OVER list_title
                FROM "reminders"
                WINDOW list_title AS (PARTITION BY "reminders"."remindersListID" ORDER BY "reminders"."title" DESC)
                """
            }
        }

        @Test func windowWithWhere() async {
            await assertSQL(
                of: Reminder.all
                    .where { $0.isCompleted }
                    .window("title_order") {
                        $0.order(by: $1.title.desc())
                    }
                    .select { ($0.title, rank().over("title_order")) }
            ) {
                """
                SELECT "reminders"."title", RANK() OVER title_order
                FROM "reminders"
                WHERE "reminders"."isCompleted"
                WINDOW title_order AS (ORDER BY "reminders"."title" DESC)
                """
            }
        }

        @Test func windowWithOrderBy() async {
            await assertSQL(
                of: Reminder.all
                    .window("list_window") {
                        $0.partition(by: $1.remindersListID)
                            .order(by: $1.title.desc())
                    }
                    .select { ($0.title, rank().over("list_window")) }
                    .order { $0.title }
            ) {
                """
                SELECT "reminders"."title", RANK() OVER list_window
                FROM "reminders"
                WINDOW list_window AS (PARTITION BY "reminders"."remindersListID" ORDER BY "reminders"."title" DESC)
                ORDER BY "reminders"."title"
                """
            }
        }

        @Test func windowWithLimit() async {
            await assertSQL(
                of: Reminder.all
                    .window("title_order") {
                        $0.order(by: $1.title.desc())
                    }
                    .select { ($0.title, $0.remindersListID, rank().over("title_order")) }
                    .limit(10)
            ) {
                """
                SELECT "reminders"."title", "reminders"."remindersListID", RANK() OVER title_order
                FROM "reminders"
                WINDOW title_order AS (ORDER BY "reminders"."title" DESC)
                LIMIT 10
                """
            }
        }

        @Test func lagLeadWithNamedWindow() async {
            await assertSQL(
                of: Reminder.all
                    .window("list_order") {
                        $0.partition(by: $1.remindersListID)
                            .order(by: $1.id)
                    }
                    .select {
                        (
                            $0.title,
                            $0.id,
                            $0.id.lag().over("list_order"),
                            $0.id.lead().over("list_order")
                        )
                    }
            ) {
                """
                SELECT "reminders"."title", "reminders"."id", LAG("reminders"."id", 1) OVER list_order, LEAD("reminders"."id", 1) OVER list_order
                FROM "reminders"
                WINDOW list_order AS (PARTITION BY "reminders"."remindersListID" ORDER BY "reminders"."id")
                """
            }
        }

        @Test func clauseOrderingValidation() async {
            await assertSQL(
                of: Reminder.all
                    .window("w") {
                        $0.order(by: $1.title)
                    }
                    .select { ($0.title, rank().over("w")) }
                    .order { $0.id }
            ) {
                """
                SELECT "reminders"."title", RANK() OVER w
                FROM "reminders"
                WINDOW w AS (ORDER BY "reminders"."title")
                ORDER BY "reminders"."id"
                """
            }
        }
    }
}
