import Foundation
import Tests_Inline_Snapshot
import PostgreSQL_Standard
import PostgreSQL_Standard_Test_Support
import Testing

extension SnapshotTests {
    @Suite struct StatisticalTests {
        // MARK: - Table.stddev Tests

        @Test
        func `Table.stddev with closure syntax`() async {
            await assertSQL(of: Order.stddev { $0.amount }) {
                """
                SELECT STDDEV("orders"."amount")
                FROM "orders"
                """
            }
        }

        @Test
        func `Table.stddev with filter using closure`() async {
            await assertSQL(of: Order.stddev(of: { $0.amount }, filter: { $0.isPaid })) {
                """
                SELECT STDDEV("orders"."amount") FILTER (WHERE "orders"."isPaid")
                FROM "orders"
                """
            }
        }

        @Test
        func `Table.stddev with Int column`() async {
            await assertSQL(of: Order.stddev { $0.quantity }) {
                """
                SELECT STDDEV("orders"."quantity")
                FROM "orders"
                """
            }
        }

        @Test
        func `Table.stddev with Double column`() async {
            await assertSQL(of: Order.stddev { $0.unitPrice }) {
                """
                SELECT STDDEV("orders"."unitPrice")
                FROM "orders"
                """
            }
        }

        // MARK: - Table.variance Tests

        @Test
        func `Table.variance with closure syntax`() async {
            await assertSQL(of: Order.variance { $0.amount }) {
                """
                SELECT VARIANCE("orders"."amount")
                FROM "orders"
                """
            }
        }

        @Test
        func `Table.variance with filter using closure`() async {
            await assertSQL(of: Order.variance(of: { $0.amount }, filter: { $0.isPaid })) {
                """
                SELECT VARIANCE("orders"."amount") FILTER (WHERE "orders"."isPaid")
                FROM "orders"
                """
            }
        }

        @Test
        func `Table.variance with Int column`() async {
            await assertSQL(of: Order.variance { $0.quantity }) {
                """
                SELECT VARIANCE("orders"."quantity")
                FROM "orders"
                """
            }
        }

        // MARK: - Where.stddev Tests

        @Test
        func `Where.stddev with closure syntax`() async {
            await assertSQL(of: Order.where { $0.isPaid }.stddev { $0.amount }) {
                """
                SELECT STDDEV("orders"."amount")
                FROM "orders"
                WHERE "orders"."isPaid"
                """
            }
        }

        @Test
        func `Where.stddev with complex WHERE clause`() async {
            await assertSQL(
                of:
                    Order
                    .where { $0.isPaid && $0.amount > 100 }
                    .stddev { $0.amount }
            ) {
                """
                SELECT STDDEV("orders"."amount")
                FROM "orders"
                WHERE ("orders"."isPaid") AND ("orders"."amount") > (100.0)
                """
            }
        }

        @Test
        func `Where.stddev with filter clause`() async {
            await assertSQL(
                of:
                    Order
                    .where { $0.createdAt > Date(timeIntervalSince1970: 0) }
                    .stddev(of: { $0.amount }, filter: { $0.isPaid })
            ) {
                """
                SELECT STDDEV("orders"."amount") FILTER (WHERE "orders"."isPaid")
                FROM "orders"
                WHERE ("orders"."createdAt") > ('1970-01-01 00:00:00.000')
                """
            }
        }

        // MARK: - Where.variance Tests

        @Test
        func `Where.variance with closure syntax`() async {
            await assertSQL(of: Order.where { $0.isPaid }.variance { $0.amount }) {
                """
                SELECT VARIANCE("orders"."amount")
                FROM "orders"
                WHERE "orders"."isPaid"
                """
            }
        }

        @Test
        func `Where.variance with complex WHERE clause`() async {
            await assertSQL(
                of:
                    Order
                    .where { $0.isPaid && $0.amount > 100 }
                    .variance { $0.amount }
            ) {
                """
                SELECT VARIANCE("orders"."amount")
                FROM "orders"
                WHERE ("orders"."isPaid") AND ("orders"."amount") > (100.0)
                """
            }
        }

        @Test
        func `Where.variance with filter clause`() async {
            await assertSQL(
                of:
                    Order
                    .where { $0.createdAt > Date(timeIntervalSince1970: 0) }
                    .variance(of: { $0.amount }, filter: { $0.isPaid })
            ) {
                """
                SELECT VARIANCE("orders"."amount") FILTER (WHERE "orders"."isPaid")
                FROM "orders"
                WHERE ("orders"."createdAt") > ('1970-01-01 00:00:00.000')
                """
            }
        }

        // MARK: - Select Tests (Low-Level API)

        @Test
        func `Select.stddev using low-level API`() async {
            await assertSQL(of: Order.select { $0.amount.stddev() }) {
                """
                SELECT stddev("orders"."amount")
                FROM "orders"
                """
            }
        }

        @Test
        func `Select.variance using low-level API`() async {
            await assertSQL(of: Order.select { $0.amount.variance() }) {
                """
                SELECT variance("orders"."amount")
                FROM "orders"
                """
            }
        }

        @Test
        func `Select.stddev appending to existing columns`() async {
            await assertSQL(of: Order.select { ($0.orderID, $0.amount.stddev()) }) {
                """
                SELECT "orders"."orderID", stddev("orders"."amount")
                FROM "orders"
                """
            }
        }

        @Test
        func `Select.stddev with join`() async {
            await assertSQL(
                of:
                    Order
                    .join(Customer.all) { $0.customerID.eq($1.id) }
                    .select { order, _ in order.amount.stddev() }
            ) {
                """
                SELECT stddev("orders"."amount")
                FROM "orders"
                JOIN "customers" ON ("orders"."customerID") = ("customers"."id")
                """
            }
        }

        @Test
        func `Select.stddev with filter`() async {
            await assertSQL(
                of: Order.select { $0.amount.stddev(filter: $0.isPaid) }
            ) {
                """
                SELECT stddev("orders"."amount") FILTER (WHERE "orders"."isPaid")
                FROM "orders"
                """
            }
        }

        // MARK: - Statistical Variants

        @Test
        func `StddevPop function`() async {
            await assertSQL(of: Order.select { $0.amount.stddevPop() }) {
                """
                SELECT stddev_pop("orders"."amount")
                FROM "orders"
                """
            }
        }

        @Test
        func `StddevSamp function`() async {
            await assertSQL(of: Order.select { $0.amount.stddevSamp() }) {
                """
                SELECT stddev_samp("orders"."amount")
                FROM "orders"
                """
            }
        }

        @Test
        func `VarPop function`() async {
            await assertSQL(of: Order.select { $0.amount.varPop() }) {
                """
                SELECT VAR_POP("orders"."amount")
                FROM "orders"
                """
            }
        }

        @Test
        func `VarSamp function`() async {
            await assertSQL(of: Order.select { $0.amount.varSamp() }) {
                """
                SELECT VAR_SAMP("orders"."amount")
                FROM "orders"
                """
            }
        }

        // MARK: - Complex Expression Tests

        @Test
        func `Stddev of calculated expression`() async {
            await assertSQL(of: Order.stddev { $0.quantity * $0.unitPrice }) {
                """
                SELECT STDDEV(("orders"."quantity") * ("orders"."unitPrice"))
                FROM "orders"
                """
            }
        }

        @Test
        func `Variance of calculated expression`() async {
            await assertSQL(of: Order.variance { $0.quantity * $0.unitPrice }) {
                """
                SELECT VARIANCE(("orders"."quantity") * ("orders"."unitPrice"))
                FROM "orders"
                """
            }
        }

        @Test
        func `Multiple statistical aggregates in one query`() async {
            await assertSQL(
                of: Order.select { ($0.amount.stddev(), $0.amount.variance()) }
            ) {
                """
                SELECT stddev("orders"."amount"), variance("orders"."amount")
                FROM "orders"
                """
            }
        }

        @Test
        func `Mix of statistical and numeric aggregates`() async {
            await assertSQL(
                of: Order.select {
                    ($0.amount.avg(), $0.amount.stddev(), $0.amount.min(), $0.amount.max())
                }
            ) {
                """
                SELECT avg("orders"."amount"), stddev("orders"."amount"), min("orders"."amount"), max("orders"."amount")
                FROM "orders"
                """
            }
        }

        // MARK: - Compile-Time Type Tests

        func compileTimeTypeTests() {
            // Verify return types compile correctly

            // Table.stddev returns Select<Double?, Order, ()>
            let _: Select<Double?, Order, ()> = Order.stddev { $0.amount }

            // Table.variance returns Select<Double?, Order, ()>
            let _: Select<Double?, Order, ()> = Order.variance { $0.amount }

            // Where.stddev returns Select<Double?, Order, ()>
            let _: Select<Double?, Order, ()> = Order.where { $0.isPaid }.stddev { $0.amount }

            // Where.variance returns Select<Double?, Order, ()>
            let _: Select<Double?, Order, ()> = Order.where { $0.isPaid }.variance { $0.amount }

            // Int column returns Double?
            let _: Select<Double?, Order, ()> = Order.stddev { $0.quantity }
        }

        // MARK: - Edge Cases

        @Test
        func `Stddev with GROUP BY`() async {
            await assertSQL(
                of:
                    Order
                    .group(by: \.customerID)
                    .select { ($0.customerID, $0.amount.stddev()) }
            ) {
                """
                SELECT "orders"."customerID", stddev("orders"."amount")
                FROM "orders"
                GROUP BY "orders"."customerID"
                """
            }
        }

        @Test
        func `Variance with GROUP BY`() async {
            await assertSQL(
                of:
                    Order
                    .group(by: \.customerID)
                    .select { ($0.customerID, $0.amount.variance()) }
            ) {
                """
                SELECT "orders"."customerID", variance("orders"."amount")
                FROM "orders"
                GROUP BY "orders"."customerID"
                """
            }
        }

        @Test
        func `Stddev with HAVING clause`() async {
            await assertSQL(
                of:
                    Order
                    .group(by: \.customerID)
                    .select { ($0.customerID, $0.amount.stddev()) }
                    .having { $0.amount.stddev() > 10.0 }
            ) {
                """
                SELECT "orders"."customerID", stddev("orders"."amount")
                FROM "orders"
                GROUP BY "orders"."customerID"
                HAVING (stddev("orders"."amount")) > (10.0)
                """
            }
        }

        @Test
        func `Variance with HAVING clause`() async {
            await assertSQL(
                of:
                    Order
                    .group(by: \.customerID)
                    .select { ($0.customerID, $0.amount.variance()) }
                    .having { $0.amount.variance() > 100.0 }
            ) {
                """
                SELECT "orders"."customerID", variance("orders"."amount")
                FROM "orders"
                GROUP BY "orders"."customerID"
                HAVING (variance("orders"."amount")) > (100.0)
                """
            }
        }

        @Test
        func `Stddev with ORDER BY`() async {
            await assertSQL(
                of:
                    Order
                    .group(by: \.customerID)
                    .order { $0.amount.stddev().desc() }
                    .select { ($0.customerID, $0.amount.stddev()) }
            ) {
                """
                SELECT "orders"."customerID", stddev("orders"."amount")
                FROM "orders"
                GROUP BY "orders"."customerID"
                ORDER BY stddev("orders"."amount") DESC
                """
            }
        }

        @Test
        func `Stddev with multiple GROUP BY columns`() async {
            await assertSQL(
                of:
                    Order
                    .group(by: \.customerID)
                    .group(by: \.isPaid)
                    .select { ($0.customerID, $0.isPaid, $0.amount.stddev()) }
            ) {
                """
                SELECT "orders"."customerID", "orders"."isPaid", stddev("orders"."amount")
                FROM "orders"
                GROUP BY "orders"."customerID", "orders"."isPaid"
                """
            }
        }

    }
}
