import Foundation
import PostgreSQL_Standard
import PostgreSQL_Standard_Test_Support
import Testing
import Tests_Inline_Snapshot

extension SnapshotTests.Commands.Select {
    @Suite struct FrameClauseTests {

        @Test func rowsUnboundedPrecedingToCurrentRow() async {
            await assertSQL(
                of: Reminder.all
                    .select {
                        let listID = $0.remindersListID
                        let id = $0.id
                        return (
                            $0.title,
                            rowNumber().over {
                                $0.partition(by: listID)
                                    .order(by: id)
                                    .rows(
                                        between: FrameBound.unboundedPreceding,
                                        and: FrameBound.currentRow
                                    )
                            }
                        )
                    }
            ) {
                """
                SELECT "reminders"."title", ROW_NUMBER() OVER (PARTITION BY "reminders"."remindersListID" ORDER BY "reminders"."id" ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
                FROM "reminders"
                """
            }
        }

        @Test func rowsNPrecedingToCurrentRow() async {
            await assertSQL(
                of: Reminder.all
                    .select {
                        let id = $0.id
                        return (
                            $0.title,
                            rowNumber().over {
                                $0.order(by: id)
                                    .rows(
                                        between: FrameBound.preceding(2),
                                        and: FrameBound.currentRow
                                    )
                            }
                        )
                    }
            ) {
                """
                SELECT "reminders"."title", ROW_NUMBER() OVER (ORDER BY "reminders"."id" ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
                FROM "reminders"
                """
            }
        }

        @Test func rowsCurrentRowToNFollowing() async {
            await assertSQL(
                of: Reminder.all
                    .select {
                        let id = $0.id
                        return (
                            $0.title,
                            rank().over {
                                $0.order(by: id)
                                    .rows(
                                        between: FrameBound.currentRow,
                                        and: FrameBound.following(3)
                                    )
                            }
                        )
                    }
            ) {
                """
                SELECT "reminders"."title", RANK() OVER (ORDER BY "reminders"."id" ROWS BETWEEN CURRENT ROW AND 3 FOLLOWING)
                FROM "reminders"
                """
            }
        }

        @Test func rowsCurrentRowToUnboundedFollowing() async {
            await assertSQL(
                of: Reminder.all
                    .select {
                        let id = $0.id
                        return (
                            $0.title,
                            denseRank().over {
                                $0.order(by: id)
                                    .rows(
                                        between: FrameBound.currentRow,
                                        and: FrameBound.unboundedFollowing
                                    )
                            }
                        )
                    }
            ) {
                """
                SELECT "reminders"."title", DENSE_RANK() OVER (ORDER BY "reminders"."id" ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING)
                FROM "reminders"
                """
            }
        }

        @Test func rowsEntirePartition() async {
            await assertSQL(
                of: Reminder.all
                    .select {
                        let listID = $0.remindersListID
                        let id = $0.id
                        return (
                            $0.title,
                            rowNumber().over {
                                $0.partition(by: listID)
                                    .order(by: id)
                                    .rows(
                                        between: FrameBound.unboundedPreceding,
                                        and: FrameBound.unboundedFollowing
                                    )
                            }
                        )
                    }
            ) {
                """
                SELECT "reminders"."title", ROW_NUMBER() OVER (PARTITION BY "reminders"."remindersListID" ORDER BY "reminders"."id" ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
                FROM "reminders"
                """
            }
        }

        @Test func rowsSymmetricWindow() async {
            await assertSQL(
                of: Reminder.all
                    .select {
                        let id = $0.id
                        return (
                            $0.title,
                            rank().over {
                                $0.order(by: id)
                                    .rows(
                                        between: FrameBound.preceding(2),
                                        and: FrameBound.following(2)
                                    )
                            }
                        )
                    }
            ) {
                """
                SELECT "reminders"."title", RANK() OVER (ORDER BY "reminders"."id" ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING)
                FROM "reminders"
                """
            }
        }

        @Test func rowsShorthandPreceding() async {
            await assertSQL(
                of: Reminder.all
                    .select {
                        let id = $0.id
                        return (
                            $0.title,
                            rowNumber().over {
                                $0.order(by: id)
                                    .rows(FrameBound.preceding(5))
                            }
                        )
                    }
            ) {
                """
                SELECT "reminders"."title", ROW_NUMBER() OVER (ORDER BY "reminders"."id" ROWS 5 PRECEDING)
                FROM "reminders"
                """
            }
        }

        @Test func rowsShorthandUnboundedPreceding() async {
            await assertSQL(
                of: Reminder.all
                    .select {
                        let id = $0.id
                        return (
                            $0.title,
                            rank().over {
                                $0.order(by: id)
                                    .rows(FrameBound.unboundedPreceding)
                            }
                        )
                    }
            ) {
                """
                SELECT "reminders"."title", RANK() OVER (ORDER BY "reminders"."id" ROWS UNBOUNDED PRECEDING)
                FROM "reminders"
                """
            }
        }

        @Test func rowsShorthandCurrentRow() async {
            await assertSQL(
                of: Reminder.all
                    .select {
                        let id = $0.id
                        return (
                            $0.title,
                            rowNumber().over {
                                $0.order(by: id)
                                    .rows(FrameBound.currentRow)
                            }
                        )
                    }
            ) {
                """
                SELECT "reminders"."title", ROW_NUMBER() OVER (ORDER BY "reminders"."id" ROWS CURRENT ROW)
                FROM "reminders"
                """
            }
        }

        @Test func rangeUnboundedPrecedingToCurrentRow() async {
            await assertSQL(
                of: Reminder.all
                    .select {
                        let id = $0.id
                        return (
                            $0.title,
                            rank().over {
                                $0.order(by: id)
                                    .range(
                                        between: FrameBound.unboundedPreceding,
                                        and: FrameBound.currentRow
                                    )
                            }
                        )
                    }
            ) {
                """
                SELECT "reminders"."title", RANK() OVER (ORDER BY "reminders"."id" RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
                FROM "reminders"
                """
            }
        }

        @Test func rangeEntirePartition() async {
            await assertSQL(
                of: Reminder.all
                    .select {
                        let listID = $0.remindersListID
                        let id = $0.id
                        return (
                            $0.title,
                            rowNumber().over {
                                $0.partition(by: listID)
                                    .order(by: id)
                                    .range(
                                        between: FrameBound.unboundedPreceding,
                                        and: FrameBound.unboundedFollowing
                                    )
                            }
                        )
                    }
            ) {
                """
                SELECT "reminders"."title", ROW_NUMBER() OVER (PARTITION BY "reminders"."remindersListID" ORDER BY "reminders"."id" RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
                FROM "reminders"
                """
            }
        }

        @Test func rangeShorthand() async {
            await assertSQL(
                of: Reminder.all
                    .select {
                        let id = $0.id
                        return (
                            $0.title,
                            rank().over {
                                $0.order(by: id)
                                    .range(FrameBound.unboundedPreceding)
                            }
                        )
                    }
            ) {
                """
                SELECT "reminders"."title", RANK() OVER (ORDER BY "reminders"."id" RANGE UNBOUNDED PRECEDING)
                FROM "reminders"
                """
            }
        }

        @Test func groupsUnboundedPrecedingToCurrentRow() async {
            await assertSQL(
                of: Reminder.all
                    .select {
                        let priority = $0.priority
                        return (
                            $0.title,
                            rank().over {
                                $0.order(by: priority)
                                    .groups(
                                        between: FrameBound.unboundedPreceding,
                                        and: FrameBound.currentRow
                                    )
                            }
                        )
                    }
            ) {
                """
                SELECT "reminders"."title", RANK() OVER (ORDER BY "reminders"."priority" GROUPS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
                FROM "reminders"
                """
            }
        }

        @Test func groupsNPrecedingToCurrentRow() async {
            await assertSQL(
                of: Reminder.all
                    .select {
                        let priority = $0.priority
                        return (
                            $0.title,
                            denseRank().over {
                                $0.order(by: priority)
                                    .groups(
                                        between: FrameBound.preceding(1),
                                        and: FrameBound.currentRow
                                    )
                            }
                        )
                    }
            ) {
                """
                SELECT "reminders"."title", DENSE_RANK() OVER (ORDER BY "reminders"."priority" GROUPS BETWEEN 1 PRECEDING AND CURRENT ROW)
                FROM "reminders"
                """
            }
        }

        @Test func groupsShorthand() async {
            await assertSQL(
                of: Reminder.all
                    .select {
                        let priority = $0.priority
                        return (
                            $0.title,
                            rank().over {
                                $0.order(by: priority)
                                    .groups(FrameBound.preceding(2))
                            }
                        )
                    }
            ) {
                """
                SELECT "reminders"."title", RANK() OVER (ORDER BY "reminders"."priority" GROUPS 2 PRECEDING)
                FROM "reminders"
                """
            }
        }

        @Test func lastValueWithCorrectFrame() async {
            await assertSQL(
                of: Reminder.all
                    .select {
                        let title = $0.title
                        let listID = $0.remindersListID
                        let id = $0.id
                        return (
                            $0.id,
                            title.lastValue().over {
                                $0.partition(by: listID)
                                    .order(by: id)
                                    .rows(
                                        between: FrameBound.unboundedPreceding,
                                        and: FrameBound.unboundedFollowing
                                    )
                            }
                        )
                    }
            ) {
                """
                SELECT "reminders"."id", LAST_VALUE("reminders"."title") OVER (PARTITION BY "reminders"."remindersListID" ORDER BY "reminders"."id" ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
                FROM "reminders"
                """
            }
        }

        @Test func firstValueWithFrame() async {
            await assertSQL(
                of: Reminder.all
                    .select {
                        let title = $0.title
                        let listID = $0.remindersListID
                        let id = $0.id
                        return (
                            $0.id,
                            title.firstValue().over {
                                $0.partition(by: listID)
                                    .order(by: id)
                                    .rows(
                                        between: FrameBound.unboundedPreceding,
                                        and: FrameBound.currentRow
                                    )
                            }
                        )
                    }
            ) {
                """
                SELECT "reminders"."id", FIRST_VALUE("reminders"."title") OVER (PARTITION BY "reminders"."remindersListID" ORDER BY "reminders"."id" ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
                FROM "reminders"
                """
            }
        }

        @Test func nthValueWithFrame() async {
            await assertSQL(
                of: Reminder.all
                    .select {
                        let title = $0.title
                        let listID = $0.remindersListID
                        let id = $0.id
                        return (
                            $0.id,
                            title.nthValue(3).over {
                                $0.partition(by: listID)
                                    .order(by: id)
                                    .rows(
                                        between: FrameBound.unboundedPreceding,
                                        and: FrameBound.unboundedFollowing
                                    )
                            }
                        )
                    }
            ) {
                """
                SELECT "reminders"."id", NTH_VALUE("reminders"."title", 3) OVER (PARTITION BY "reminders"."remindersListID" ORDER BY "reminders"."id" ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
                FROM "reminders"
                """
            }
        }

        @Test func frameWithNamedWindow() async {
            await assertSQL(
                of: Reminder.all
                    .window("frame_window") { spec, cols in
                        spec.partition(by: cols.remindersListID)
                            .order(by: cols.id)
                            .rows(
                                between: FrameBound.unboundedPreceding,
                                and: FrameBound.currentRow
                            )
                    }
                    .select { ($0.title, rowNumber().over("frame_window")) }
            ) {
                """
                SELECT "reminders"."title", ROW_NUMBER() OVER frame_window
                FROM "reminders"
                WINDOW frame_window AS (PARTITION BY "reminders"."remindersListID" ORDER BY "reminders"."id" ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
                """
            }
        }

        @Test func frameWithoutPartition() async {
            await assertSQL(
                of: Reminder.all
                    .select {
                        let id = $0.id
                        return (
                            $0.title,
                            rowNumber().over {
                                $0.order(by: id)
                                    .rows(
                                        between: FrameBound.unboundedPreceding,
                                        and: FrameBound.currentRow
                                    )
                            }
                        )
                    }
            ) {
                """
                SELECT "reminders"."title", ROW_NUMBER() OVER (ORDER BY "reminders"."id" ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
                FROM "reminders"
                """
            }
        }

        @Test func frameWithoutOrderBy() async {
            await assertSQL(
                of: Reminder.all
                    .select {
                        let listID = $0.remindersListID
                        return (
                            $0.title,
                            rowNumber().over {
                                $0.partition(by: listID)
                                    .rows(
                                        between: FrameBound.unboundedPreceding,
                                        and: FrameBound.unboundedFollowing
                                    )
                            }
                        )
                    }
            ) {
                """
                SELECT "reminders"."title", ROW_NUMBER() OVER (PARTITION BY "reminders"."remindersListID" ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
                FROM "reminders"
                """
            }
        }

        @Test func singleRowFrame() async {
            await assertSQL(
                of: Reminder.all
                    .select {
                        let id = $0.id
                        return (
                            $0.title,
                            rank().over {
                                $0.order(by: id)
                                    .rows(
                                        between: FrameBound.currentRow,
                                        and: FrameBound.currentRow
                                    )
                            }
                        )
                    }
            ) {
                """
                SELECT "reminders"."title", RANK() OVER (ORDER BY "reminders"."id" ROWS BETWEEN CURRENT ROW AND CURRENT ROW)
                FROM "reminders"
                """
            }
        }

        @Test func completeWindowSpecification() async {
            await assertSQL(
                of: Reminder.all
                    .select {
                        let listID = $0.remindersListID
                        let priority = $0.priority
                        return (
                            $0.title,
                            rowNumber().over {
                                $0.partition(by: listID)
                                    .order(by: priority.desc())
                                    .rows(
                                        between: FrameBound.preceding(3),
                                        and: FrameBound.following(1)
                                    )
                            }
                        )
                    }
            ) {
                """
                SELECT "reminders"."title", ROW_NUMBER() OVER (PARTITION BY "reminders"."remindersListID" ORDER BY "reminders"."priority" DESC ROWS BETWEEN 3 PRECEDING AND 1 FOLLOWING)
                FROM "reminders"
                """
            }
        }
    }
}
