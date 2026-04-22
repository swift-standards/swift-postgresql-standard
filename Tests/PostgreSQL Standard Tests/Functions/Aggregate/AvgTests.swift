import Foundation
import Tests_Inline_Snapshot
import PostgreSQL_Standard
import PostgreSQL_Standard_Test_Support
import Testing

extension SnapshotTests {
    @Suite struct AvgTests {
        // MARK: - Table.avg Tests

        @Test
        func `Table.avg with closure syntax`() async {
            await assertSQL(of: Order.avg { $0.amount }) {
                """
                SELECT avg("orders"."amount")
                FROM "orders"
                """
            }
        }

        @Test
        func `Table.avg with KeyPath syntax`() async {
            await assertSQL(of: Order.avg(of: \.amount)) {
                """
                SELECT avg("orders"."amount")
                FROM "orders"
                """
            }
        }

        @Test
        func `Table.avg with filter using closure`() async {
            await assertSQL(of: Order.avg(of: { $0.amount }, filter: { $0.isPaid })) {
                """
                SELECT avg("orders"."amount") FILTER (WHERE "orders"."isPaid")
                FROM "orders"
                """
            }
        }

        @Test
        func `Table.avg with filter using KeyPath`() async {
            await assertSQL(of: Order.avg(of: \.amount, filter: { $0.isPaid })) {
                """
                SELECT avg("orders"."amount") FILTER (WHERE "orders"."isPaid")
                FROM "orders"
                """
            }
        }

        @Test
        func `Table.avg with Double column`() async {
            await assertSQL(of: Order.avg { $0.unitPrice }) {
                """
                SELECT avg("orders"."unitPrice")
                FROM "orders"
                """
            }
        }

        // MARK: - Where.avg Tests

        @Test
        func `Where.avg with closure syntax`() async {
            await assertSQL(of: Order.where({ $0.isPaid }).avg { $0.amount }) {
                """
                SELECT avg("orders"."amount")
                FROM "orders"
                WHERE "orders"."isPaid"
                """
            }
        }

        @Test
        func `Where.avg with KeyPath syntax`() async {
            await assertSQL(of: Order.where(\.isPaid).avg(of: \.amount)) {
                """
                SELECT avg("orders"."amount")
                FROM "orders"
                WHERE "orders"."isPaid"
                """
            }
        }

        @Test
        func `Where.avg with complex WHERE clause`() async {
            await assertSQL(
                of:
                    Order
                    .where { $0.isPaid && $0.amount > 100 }
                    .avg { $0.amount }
            ) {
                """
                SELECT avg("orders"."amount")
                FROM "orders"
                WHERE ("orders"."isPaid") AND ("orders"."amount") > (100.0)
                """
            }
        }

        @Test
        func `Where.avg with filter clause`() async {
            await assertSQL(
                of:
                    Order
                    .where { $0.createdAt > Date(timeIntervalSince1970: 0) }
                    .avg(of: \.amount, filter: { $0.isPaid })
            ) {
                """
                SELECT avg("orders"."amount") FILTER (WHERE "orders"."isPaid")
                FROM "orders"
                WHERE ("orders"."createdAt") > ('1970-01-01 00:00:00.000')
                """
            }
        }

        // MARK: - Select.avg Tests

        @Test
        func `Select.avg using low-level API`() async {
            await assertSQL(of: Order.select { $0.amount.avg() }) {
                """
                SELECT avg("orders"."amount")
                FROM "orders"
                """
            }
        }

        @Test
        func `Select.avg appending to existing columns using low-level`() async {
            await assertSQL(of: Order.select { ($0.orderID, $0.amount.avg()) }) {
                """
                SELECT "orders"."orderID", avg("orders"."amount")
                FROM "orders"
                """
            }
        }

        @Test
        func `Select.avg with join using low-level API`() async {
            await assertSQL(
                of:
                    Order
                    .join(Customer.all) { $0.customerID.eq($1.id) }
                    .select { order, _ in order.amount.avg() }
            ) {
                """
                SELECT avg("orders"."amount")
                FROM "orders"
                JOIN "customers" ON ("orders"."customerID") = ("customers"."id")
                """
            }
        }

        @Test
        func `Select.avg with join and existing columns using low-level`() async {
            await assertSQL(
                of:
                    Order
                    .join(Customer.all) { $0.customerID.eq($1.id) }
                    .select { ($1.name, $0.amount.avg()) }
            ) {
                """
                SELECT "customers"."name", avg("orders"."amount")
                FROM "orders"
                JOIN "customers" ON ("orders"."customerID") = ("customers"."id")
                """
            }
        }

        @Test
        func `Select.avg accessing joined table columns using low-level`() async {
            await assertSQL(
                of:
                    Order
                    .join(LineItem.all) { $0.orderID.eq($1.orderID) }
                    .select { _, lineItem in (lineItem.price * lineItem.quantity).avg() }
            ) {
                """
                SELECT avg(("lineItems"."price") * ("lineItems"."quantity"))
                FROM "orders"
                JOIN "lineItems" ON ("orders"."orderID") = ("lineItems"."orderID")
                """
            }
        }

        // MARK: - Nullable Column Tests

        @Test
        func `Avg of nullable column returns single optional`() async {
            // Test that nullable column (discount: Double?) returns Select<Double?, ...>
            // NOT Select<Double??, ...> (double optional)
            await assertSQL(of: Order.avg { $0.discount }) {
                """
                SELECT avg("orders"."discount")
                FROM "orders"
                """
            }
        }

        @Test
        func `Avg with DISTINCT`() async {
            await assertSQL(of: Order.select { $0.amount.avg(distinct: true) }) {
                """
                SELECT avg(DISTINCT "orders"."amount")
                FROM "orders"
                """
            }
        }

        // MARK: - Complex Expression Tests

        @Test
        func `Avg of calculated expression`() async {
            await assertSQL(of: Order.avg { $0.quantity * $0.unitPrice }) {
                """
                SELECT avg(("orders"."quantity") * ("orders"."unitPrice"))
                FROM "orders"
                """
            }
        }

        @Test
        func `Multiple aggregates in one query`() async {
            await assertSQL(
                of: Order.select { ($0.amount.avg(), $0.quantity.avg()) }
            ) {
                """
                SELECT avg("orders"."amount"), avg("orders"."quantity")
                FROM "orders"
                """
            }
        }

        // MARK: - Compile-Time Type Tests

        func compileTimeTypeTests() {
            // Verify return types compile correctly

            // Table.avg returns Select<Double?, Order, ()>
            let _: Select<Double?, Order, ()> = Order.avg { $0.amount }
            let _: Select<Double?, Order, ()> = Order.avg(of: \.amount)

            // Where.avg returns Select<Double?, Order, ()>
            let _: Select<Double?, Order, ()> = Order.where { $0.isPaid }.avg { $0.amount }
            let _: Select<Double?, Order, ()> = Order.where { $0.isPaid }.avg(of: \.amount)

            // Double column returns Double?
            let _: Select<Double?, Order, ()> = Order.avg { $0.quantity }

            // Nullable column returns single optional, not double
            let _: Select<Double?, Order, ()> = Order.avg { $0.discount }

            // Complex expression
            let _: Select<Double?, Order, ()> = Order.avg { $0.quantity * $0.unitPrice }
        }

        // MARK: - Edge Cases

        @Test
        func `Avg with GROUP BY`() async {
            await assertSQL(
                of:
                    Order
                    .group(by: \.customerID)
                    .select { ($0.customerID, $0.amount.avg()) }
            ) {
                """
                SELECT "orders"."customerID", avg("orders"."amount")
                FROM "orders"
                GROUP BY "orders"."customerID"
                """
            }
        }

        @Test
        func `Avg with ORDER BY the average`() async {
            await assertSQL(
                of:
                    Order
                    .group(by: \.customerID)
                    .order { $0.amount.avg().desc() }
                    .select { ($0.customerID, $0.amount.avg()) }
            ) {
                """
                SELECT "orders"."customerID", avg("orders"."amount")
                FROM "orders"
                GROUP BY "orders"."customerID"
                ORDER BY avg("orders"."amount") DESC
                """
            }
        }

        @Test
        func `Avg with HAVING clause`() async {
            await assertSQL(
                of:
                    Order
                    .group(by: \.customerID)
                    .select { ($0.customerID, $0.amount.avg()) }
                    .having { $0.amount.avg() > 1000.0 }
            ) {
                """
                SELECT "orders"."customerID", avg("orders"."amount")
                FROM "orders"
                GROUP BY "orders"."customerID"
                HAVING (avg("orders"."amount")) > (1000.0)
                """
            }
        }

        @Test
        func `Avg with HAVING and WHERE`() async {
            await assertSQL(
                of:
                    Order
                    .where { $0.isPaid }
                    .group(by: \.customerID)
                    .select { ($0.customerID, $0.amount.avg()) }
                    .having { $0.amount.avg() > 500.0 }
            ) {
                """
                SELECT "orders"."customerID", avg("orders"."amount")
                FROM "orders"
                WHERE "orders"."isPaid"
                GROUP BY "orders"."customerID"
                HAVING (avg("orders"."amount")) > (500.0)
                """
            }
        }

        @Test
        func `Avg with HAVING using different operators`() async {
            // Test less than
            await assertSQL(
                of:
                    Order
                    .group(by: \.customerID)
                    .select { ($0.customerID, $0.amount.avg()) }
                    .having { $0.amount.avg() < 100.0 }
            ) {
                """
                SELECT "orders"."customerID", avg("orders"."amount")
                FROM "orders"
                GROUP BY "orders"."customerID"
                HAVING (avg("orders"."amount")) < (100.0)
                """
            }

            // Test greater than or equal
            await assertSQL(
                of:
                    Order
                    .group(by: \.customerID)
                    .select { ($0.customerID, $0.amount.avg()) }
                    .having { $0.amount.avg() >= 250.0 }
            ) {
                """
                SELECT "orders"."customerID", avg("orders"."amount")
                FROM "orders"
                GROUP BY "orders"."customerID"
                HAVING (avg("orders"."amount")) >= (250.0)
                """
            }

            // Test less than or equal
            await assertSQL(
                of:
                    Order
                    .group(by: \.customerID)
                    .select { ($0.customerID, $0.amount.avg()) }
                    .having { $0.amount.avg() <= 5000.0 }
            ) {
                """
                SELECT "orders"."customerID", avg("orders"."amount")
                FROM "orders"
                GROUP BY "orders"."customerID"
                HAVING (avg("orders"."amount")) <= (5000.0)
                """
            }
        }
    }
}
