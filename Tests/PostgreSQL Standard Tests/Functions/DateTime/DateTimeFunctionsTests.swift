import Foundation
import PostgreSQL_Standard
import PostgreSQL_Standard_Macros
import PostgreSQL_Standard_Test_Support
import Testing
import Tests_Inline_Snapshot

extension SnapshotTests.DateTime {
    @Suite("Date/Time Functions") struct DateTimeFunctionsTests {

        @Test func extractYear() async {
            await assertSQL(
                of: Event.where { $0.timestamp.extract(.year) == 2024 }
            ) {
                """
                SELECT "events"."id", "events"."title", "events"."timestamp"
                FROM "events"
                WHERE (EXTRACT(YEAR FROM "events"."timestamp")) = (2024)
                """
            }
        }

        @Test func extractMonth() async {
            await assertSQL(
                of: Event.where { $0.timestamp.extract(.month) == 10 }
            ) {
                """
                SELECT "events"."id", "events"."title", "events"."timestamp"
                FROM "events"
                WHERE (EXTRACT(MONTH FROM "events"."timestamp")) = (10)
                """
            }
        }

        @Test func extractDay() async {
            await assertSQL(
                of: Event.where { $0.timestamp.extract(.day) == 13 }
            ) {
                """
                SELECT "events"."id", "events"."title", "events"."timestamp"
                FROM "events"
                WHERE (EXTRACT(DAY FROM "events"."timestamp")) = (13)
                """
            }
        }

        @Test func extractHour() async {
            await assertSQL(
                of: Event.where { $0.timestamp.extract(.hour) >= 9 }
            ) {
                """
                SELECT "events"."id", "events"."title", "events"."timestamp"
                FROM "events"
                WHERE (EXTRACT(HOUR FROM "events"."timestamp")) >= (9)
                """
            }
        }

        @Test func extractMinute() async {
            await assertSQL(
                of: Event.where { $0.timestamp.extract(.minute) < 30 }
            ) {
                """
                SELECT "events"."id", "events"."title", "events"."timestamp"
                FROM "events"
                WHERE (EXTRACT(MINUTE FROM "events"."timestamp")) < (30)
                """
            }
        }

        @Test func extractSecond() async {
            await assertSQL(
                of: Event.select { $0.timestamp.extract(.second) }
            ) {
                """
                SELECT EXTRACT(SECOND FROM "events"."timestamp")
                FROM "events"
                """
            }
        }

        @Test func extractDayOfWeek() async {
            await assertSQL(
                of: Event.where { $0.timestamp.extract(.dow) == 0 }
            ) {
                """
                SELECT "events"."id", "events"."title", "events"."timestamp"
                FROM "events"
                WHERE (EXTRACT(DOW FROM "events"."timestamp")) = (0)
                """
            }
        }

        @Test func extractDayOfYear() async {
            await assertSQL(
                of: Event.where { $0.timestamp.extract(.doy) > 100 }
            ) {
                """
                SELECT "events"."id", "events"."title", "events"."timestamp"
                FROM "events"
                WHERE (EXTRACT(DOY FROM "events"."timestamp")) > (100)
                """
            }
        }

        @Test func extractEpoch() async {
            await assertSQL(
                of: Event.select { $0.timestamp.extract(.epoch) }
            ) {
                """
                SELECT EXTRACT(EPOCH FROM "events"."timestamp")
                FROM "events"
                """
            }
        }

        @Test func dateTruncYear() async {
            await assertSQL(
                of: Event.select { $0.timestamp.dateTrunc(.year) }
            ) {
                """
                SELECT DATE_TRUNC('year', "events"."timestamp")
                FROM "events"
                """
            }
        }

        @Test func dateTruncMonth() async {
            await assertSQL(
                of: Event.select { $0.timestamp.dateTrunc(.month) }
            ) {
                """
                SELECT DATE_TRUNC('month', "events"."timestamp")
                FROM "events"
                """
            }
        }

        @Test func dateTruncDay() async {
            await assertSQL(
                of: Event.select { $0.timestamp.dateTrunc(.day) }
            ) {
                """
                SELECT DATE_TRUNC('day', "events"."timestamp")
                FROM "events"
                """
            }
        }

        @Test func dateTruncHour() async {
            await assertSQL(
                of: Event.select { $0.timestamp.dateTrunc(.hour) }
            ) {
                """
                SELECT DATE_TRUNC('hour', "events"."timestamp")
                FROM "events"
                """
            }
        }

        @Test func dateTruncMinute() async {
            await assertSQL(
                of: Event.select { $0.timestamp.dateTrunc(.minute) }
            ) {
                """
                SELECT DATE_TRUNC('minute', "events"."timestamp")
                FROM "events"
                """
            }
        }

        @Test func dateTruncSecond() async {
            await assertSQL(
                of: Event.select { $0.timestamp.dateTrunc(.second) }
            ) {
                """
                SELECT DATE_TRUNC('second', "events"."timestamp")
                FROM "events"
                """
            }
        }

        @Test func currentTimestamp() async {
            await assertSQL(
                of: Event.where { $0.timestamp < Date.currentTimestamp }
            ) {
                """
                SELECT "events"."id", "events"."title", "events"."timestamp"
                FROM "events"
                WHERE ("events"."timestamp") < (CURRENT_TIMESTAMP)
                """
            }
        }

        @Test func currentDate() async {
            await assertSQL(
                of: Event.where { $0.timestamp >= Date.currentDate }
            ) {
                """
                SELECT "events"."id", "events"."title", "events"."timestamp"
                FROM "events"
                WHERE ("events"."timestamp") >= (CURRENT_DATE)
                """
            }
        }

        @Test func groupByMonth() async {
            await assertSQL(
                of: Event.select {
                    ($0.timestamp.dateTrunc(.month), $0.id.count())
                }
            ) {
                """
                SELECT DATE_TRUNC('month', "events"."timestamp"), count("events"."id")
                FROM "events"
                """
            }
        }

        @Test func filterByYearAndMonth() async {
            await assertSQL(
                of: Event.where {
                    $0.timestamp.extract(.year) == 2024 && $0.timestamp.extract(.month) == 10
                }
            ) {
                """
                SELECT "events"."id", "events"."title", "events"."timestamp"
                FROM "events"
                WHERE ((EXTRACT(YEAR FROM "events"."timestamp")) = (2024)) AND (EXTRACT(MONTH FROM "events"."timestamp")) = (10)
                """
            }
        }

        @Test
        func `EXTRACT returns correct types - epoch returns Double`() async {

            await assertSQL(
                of: Event.where { $0.timestamp.extract(.epoch) > 1700000000.0 }
            ) {
                """
                SELECT "events"."id", "events"."title", "events"."timestamp"
                FROM "events"
                WHERE (EXTRACT(EPOCH FROM "events"."timestamp")) > (1700000000.0)
                """
            }
        }

        @Test
        func `EXTRACT returns correct types - second returns Double with fractional parts`() async {

            await assertSQL(
                of: Event.where { $0.timestamp.extract(.second) >= 30.5 }
            ) {
                """
                SELECT "events"."id", "events"."title", "events"."timestamp"
                FROM "events"
                WHERE (EXTRACT(SECOND FROM "events"."timestamp")) >= (30.5)
                """
            }
        }

        @Test
        func `EXTRACT returns correct types - year returns Int`() async {

            await assertSQL(
                of: Event.where { $0.timestamp.extract(.year) + 1 == 2025 }
            ) {
                """
                SELECT "events"."id", "events"."title", "events"."timestamp"
                FROM "events"
                WHERE ((EXTRACT(YEAR FROM "events"."timestamp")) + (1)) = (2025)
                """
            }
        }

        @Test
        func `Filter events during business hours (9 AM - 5 PM)`() async {

            await assertSQL(
                of: Event.where {
                    $0.timestamp.extract(.hour) >= 9 && $0.timestamp.extract(.hour) < 17
                }
            ) {
                """
                SELECT "events"."id", "events"."title", "events"."timestamp"
                FROM "events"
                WHERE ((EXTRACT(HOUR FROM "events"."timestamp")) >= (9)) AND (EXTRACT(HOUR FROM "events"."timestamp")) < (17)
                """
            }
        }

        @Test
        func `Find weekend events (Saturday and Sunday)`() async {

            await assertSQL(
                of: Event.where {
                    $0.timestamp.extract(.dow) == 0 || $0.timestamp.extract(.dow) == 6
                }
            ) {
                """
                SELECT "events"."id", "events"."title", "events"."timestamp"
                FROM "events"
                WHERE ((EXTRACT(DOW FROM "events"."timestamp")) = (0)) OR (EXTRACT(DOW FROM "events"."timestamp")) = (6)
                """
            }
        }

        @Test
        func `Find events in first quarter of the year`() async {

            await assertSQL(
                of: Event.where {
                    $0.timestamp.extract(.month) >= 1 && $0.timestamp.extract(.month) <= 3
                }
            ) {
                """
                SELECT "events"."id", "events"."title", "events"."timestamp"
                FROM "events"
                WHERE ((EXTRACT(MONTH FROM "events"."timestamp")) >= (1)) AND (EXTRACT(MONTH FROM "events"."timestamp")) <= (3)
                """
            }
        }

        @Test
        func `Group events by day for daily analytics`() async {

            await assertSQL(
                of: Event.select {
                    ($0.timestamp.dateTrunc(.day), $0.id.count())
                }
            ) {
                """
                SELECT DATE_TRUNC('day', "events"."timestamp"), count("events"."id")
                FROM "events"
                """
            }
        }

        @Test
        func `Group events by hour for hourly analytics`() async {

            await assertSQL(
                of: Event.select {
                    ($0.timestamp.dateTrunc(.hour), $0.id.count())
                }
            ) {
                """
                SELECT DATE_TRUNC('hour', "events"."timestamp"), count("events"."id")
                FROM "events"
                """
            }
        }

        @Test
        func `Get start of current month for comparison`() async {

            await assertSQL(
                of: Event.where { $0.timestamp >= Date.currentDate.dateTrunc(.month) }
            ) {
                """
                SELECT "events"."id", "events"."title", "events"."timestamp"
                FROM "events"
                WHERE ("events"."timestamp") >= (DATE_TRUNC('month', CURRENT_DATE))
                """
            }
        }

        @Test
        func `Calculate seconds since epoch for time comparison`() async {

            await assertSQL(
                of: Event.select {
                    $0.timestamp.extract(.epoch)
                }
            ) {
                """
                SELECT EXTRACT(EPOCH FROM "events"."timestamp")
                FROM "events"
                """
            }
        }

        @Test
        func `Filter events from last 7 days using epoch`() async {

            let sevenDaysAgo = Date.currentTimestamp.extract(.epoch) - (7 * 24 * 60 * 60)
            await assertSQL(
                of: Event.where { $0.timestamp.extract(.epoch) > sevenDaysAgo }
            ) {
                """
                SELECT "events"."id", "events"."title", "events"."timestamp"
                FROM "events"
                WHERE (EXTRACT(EPOCH FROM "events"."timestamp")) > (EXTRACT(EPOCH FROM CURRENT_TIMESTAMP)) - (604800.0)
                """
            }
        }

        @Test
        func `Handle events at midnight (hour = 0)`() async {

            await assertSQL(
                of: Event.where { $0.timestamp.extract(.hour) == 0 }
            ) {
                """
                SELECT "events"."id", "events"."title", "events"."timestamp"
                FROM "events"
                WHERE (EXTRACT(HOUR FROM "events"."timestamp")) = (0)
                """
            }
        }

        @Test
        func `Handle events on first day of year (doy = 1)`() async {

            await assertSQL(
                of: Event.where { $0.timestamp.extract(.doy) == 1 }
            ) {
                """
                SELECT "events"."id", "events"."title", "events"."timestamp"
                FROM "events"
                WHERE (EXTRACT(DOY FROM "events"."timestamp")) = (1)
                """
            }
        }

        @Test
        func `Handle events on last day of year (doy = 365 or 366)`() async {

            await assertSQL(
                of: Event.where { $0.timestamp.extract(.doy) >= 365 }
            ) {
                """
                SELECT "events"."id", "events"."title", "events"."timestamp"
                FROM "events"
                WHERE (EXTRACT(DOY FROM "events"."timestamp")) >= (365)
                """
            }
        }

        @Test
        func `Find events with fractional seconds (millisecond precision)`() async {

            await assertSQL(
                of: Event.where { $0.timestamp.extract(.second) > 45.123 }
            ) {
                """
                SELECT "events"."id", "events"."title", "events"."timestamp"
                FROM "events"
                WHERE (EXTRACT(SECOND FROM "events"."timestamp")) > (45.123)
                """
            }
        }

        @Test
        func `Monthly event summary with date truncation`() async {

            await assertSQL(
                of: Event.select {
                    MonthlyEventSummary.Columns(
                        monthStart: $0.timestamp.dateTrunc(.month),
                        eventCount: $0.id.count(),
                        year: $0.timestamp.extract(.year),
                        month: $0.timestamp.extract(.month)
                    )
                }
            ) {
                """
                SELECT DATE_TRUNC('month', "events"."timestamp") AS "monthStart", count("events"."id") AS "eventCount", EXTRACT(YEAR FROM "events"."timestamp") AS "year", EXTRACT(MONTH FROM "events"."timestamp") AS "month"
                FROM "events"
                """
            }
        }

        @Test
        func `Find events in current year`() async {

            await assertSQL(
                of: Event.where { $0.timestamp.extract(.year) == Date.currentDate.extract(.year) }
            ) {
                """
                SELECT "events"."id", "events"."title", "events"."timestamp"
                FROM "events"
                WHERE (EXTRACT(YEAR FROM "events"."timestamp")) = (EXTRACT(YEAR FROM CURRENT_DATE))
                """
            }
        }

        @Test
        func `Find events happening today`() async {

            await assertSQL(
                of: Event.where { $0.timestamp.dateTrunc(.day) == Date.currentDate }
            ) {
                """
                SELECT "events"."id", "events"."title", "events"."timestamp"
                FROM "events"
                WHERE (DATE_TRUNC('day', "events"."timestamp")) = (CURRENT_DATE)
                """
            }
        }

        @Test
        func `Find events in current hour`() async {

            await assertSQL(
                of: Event.where {
                    $0.timestamp.dateTrunc(.hour) == Date.currentTimestamp.dateTrunc(.hour)
                }
            ) {
                """
                SELECT "events"."id", "events"."title", "events"."timestamp"
                FROM "events"
                WHERE (DATE_TRUNC('hour', "events"."timestamp")) = (DATE_TRUNC('hour', CURRENT_TIMESTAMP))
                """
            }
        }

        @Test
        func `Calculate event age in seconds`() async {

            await assertSQL(
                of: Event.select {
                    Date.currentTimestamp.extract(.epoch) - $0.timestamp.extract(.epoch)
                }
            ) {
                """
                SELECT (EXTRACT(EPOCH FROM CURRENT_TIMESTAMP)) - (EXTRACT(EPOCH FROM "events"."timestamp"))
                FROM "events"
                """
            }
        }

        @Test
        func `Filter events by multiple time criteria`() async {

            await assertSQL(
                of: Event.where {

                    ($0.timestamp.extract(.month) >= 1 && $0.timestamp.extract(.month) <= 3)

                        && ($0.timestamp.extract(.dow) >= 1 && $0.timestamp.extract(.dow) <= 5)

                        && ($0.timestamp.extract(.hour) >= 9 && $0.timestamp.extract(.hour) < 17)
                }
            ) {
                """
                SELECT "events"."id", "events"."title", "events"."timestamp"
                FROM "events"
                WHERE ((((EXTRACT(MONTH FROM "events"."timestamp")) >= (1)) AND (EXTRACT(MONTH FROM "events"."timestamp")) <= (3)) AND ((EXTRACT(DOW FROM "events"."timestamp")) >= (1)) AND (EXTRACT(DOW FROM "events"."timestamp")) <= (5)) AND ((EXTRACT(HOUR FROM "events"."timestamp")) >= (9)) AND (EXTRACT(HOUR FROM "events"."timestamp")) < (17)
                """
            }
        }
    }
}

@Table
private struct Event {
    let id: Int
    let title: String
    let timestamp: Date
}

@Selection
private struct MonthlyEventSummary {
    let monthStart: Date
    let eventCount: Int
    let year: Int
    let month: Int
}

extension SnapshotTests {
    enum DateTime {}
}
