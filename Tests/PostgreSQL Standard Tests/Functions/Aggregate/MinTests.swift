import Foundation
import PostgreSQL_Standard
import PostgreSQL_Standard_Test_Support
import Testing
import Tests_Inline_Snapshot

extension SnapshotTests {
    @Suite struct MinTests {

        @Test
        func `Table.min with closure syntax`() async {
            await assertSQL(of: Order.min { $0.amount }) {
                """
                SELECT min("orders"."amount")
                FROM "orders"
                """
            }
        }

        @Test
        func `Table.min with KeyPath syntax`() async {
            await assertSQL(of: Order.min(of: \.amount)) {
                """
                SELECT min("orders"."amount")
                FROM "orders"
                """
            }
        }

        @Test
        func `Table.min with filter using closure`() async {
            await assertSQL(of: Order.min(of: { $0.amount }, filter: { $0.isPaid })) {
                """
                SELECT min("orders"."amount") FILTER (WHERE "orders"."isPaid")
                FROM "orders"
                """
            }
        }

        @Test
        func `Table.min with filter using KeyPath`() async {
            await assertSQL(of: Order.min(of: \.amount, filter: { $0.isPaid })) {
                """
                SELECT min("orders"."amount") FILTER (WHERE "orders"."isPaid")
                FROM "orders"
                """
            }
        }

        @Test
        func `Table.min with Double column`() async {
            await assertSQL(of: Order.min { $0.unitPrice }) {
                """
                SELECT min("orders"."unitPrice")
                FROM "orders"
                """
            }
        }

        @Test
        func `Table.min with Int column`() async {
            await assertSQL(of: Order.min { $0.customerID }) {
                """
                SELECT min("orders"."customerID")
                FROM "orders"
                """
            }
        }

        @Test
        func `Table.min with Date column`() async {
            await assertSQL(of: Order.min { $0.createdAt }) {
                """
                SELECT min("orders"."createdAt")
                FROM "orders"
                """
            }
        }

        @Test
        func `Where.min with closure syntax`() async {
            await assertSQL(of: Order.where({ $0.isPaid }).min { $0.amount }) {
                """
                SELECT min("orders"."amount")
                FROM "orders"
                WHERE "orders"."isPaid"
                """
            }
        }

        @Test
        func `Where.min with KeyPath syntax`() async {
            await assertSQL(of: Order.where(\.isPaid).min(of: \.amount)) {
                """
                SELECT min("orders"."amount")
                FROM "orders"
                WHERE "orders"."isPaid"
                """
            }
        }

        @Test
        func `Where.min with complex WHERE clause`() async {
            await assertSQL(
                of:
                    Order
                    .where { $0.isPaid && $0.amount > 100 }
                    .min { $0.amount }
            ) {
                """
                SELECT min("orders"."amount")
                FROM "orders"
                WHERE ("orders"."isPaid") AND ("orders"."amount") > (100.0)
                """
            }
        }

        @Test
        func `Where.min with filter clause`() async {
            await assertSQL(
                of:
                    Order
                    .where { $0.createdAt > Date(timeIntervalSince1970: 0) }
                    .min(of: \.amount, filter: { $0.isPaid })
            ) {
                """
                SELECT min("orders"."amount") FILTER (WHERE "orders"."isPaid")
                FROM "orders"
                WHERE ("orders"."createdAt") > ('1970-01-01 00:00:00.000')
                """
            }
        }

        @Test
        func `Select.min using low-level API`() async {
            await assertSQL(of: Order.select { $0.amount.min() }) {
                """
                SELECT min("orders"."amount")
                FROM "orders"
                """
            }
        }

        @Test
        func `Select.min appending to existing columns using low-level`() async {
            await assertSQL(of: Order.select { ($0.orderID, $0.amount.min()) }) {
                """
                SELECT "orders"."orderID", min("orders"."amount")
                FROM "orders"
                """
            }
        }

        @Test
        func `Select.min with join using low-level API`() async {
            await assertSQL(
                of:
                    Order
                    .join(Customer.all) { $0.customerID.eq($1.id) }
                    .select { order, _ in order.amount.min() }
            ) {
                """
                SELECT min("orders"."amount")
                FROM "orders"
                JOIN "customers" ON ("orders"."customerID") = ("customers"."id")
                """
            }
        }

        @Test
        func `Select.min with join and existing columns using low-level`() async {
            await assertSQL(
                of:
                    Order
                    .join(Customer.all) { $0.customerID.eq($1.id) }
                    .select { ($1.name, $0.amount.min()) }
            ) {
                """
                SELECT "customers"."name", min("orders"."amount")
                FROM "orders"
                JOIN "customers" ON ("orders"."customerID") = ("customers"."id")
                """
            }
        }

        @Test
        func `Select.min accessing joined table columns using low-level`() async {
            await assertSQL(
                of:
                    Order
                    .join(LineItem.all) { $0.orderID.eq($1.orderID) }
                    .select { _, lineItem in lineItem.price.min() }
            ) {
                """
                SELECT min("lineItems"."price")
                FROM "orders"
                JOIN "lineItems" ON ("orders"."orderID") = ("lineItems"."orderID")
                """
            }
        }

        @Test
        func `Min of nullable column returns single optional`() async {

            await assertSQL(of: Order.min { $0.discount }) {
                """
                SELECT min("orders"."discount")
                FROM "orders"
                """
            }
        }

        @Test
        func `Min of calculated expression`() async {
            await assertSQL(of: Order.min { $0.quantity * $0.unitPrice }) {
                """
                SELECT min(("orders"."quantity") * ("orders"."unitPrice"))
                FROM "orders"
                """
            }
        }

        @Test
        func `Multiple aggregates including min in one query`() async {
            await assertSQL(
                of: Order.select { ($0.amount.min(), $0.amount.max()) }
            ) {
                """
                SELECT min("orders"."amount"), max("orders"."amount")
                FROM "orders"
                """
            }
        }

        func compileTimeTypeTests() {

            let _: Structured_Queries.Select<Double?, Order, ()> = Order.min {
                $0.amount
            }
            let _: Structured_Queries.Select<Double?, Order, ()> = Order.min(
                of: \.amount
            )

            let _: Structured_Queries.Select<Double?, Order, ()> = Order.where {
                $0.isPaid
            }.min {
                $0.amount
            }
            let _: Structured_Queries.Select<Double?, Order, ()> = Order.where {
                $0.isPaid
            }.min(
                of: \.amount
            )

            let _: Structured_Queries.Select<Int?, Order, ()> = Order.min {
                $0.customerID
            }

            let _: Structured_Queries.Select<Date?, Order, ()> = Order.min {
                $0.createdAt
            }

            let _: Structured_Queries.Select<Double?, Order, ()> = Order.min {
                $0.discount
            }

            let _: Structured_Queries.Select<Double?, Order, ()> = Order.min {
                $0.quantity * $0.unitPrice
            }
        }

        @Test
        func `Min with GROUP BY`() async {
            await assertSQL(
                of:
                    Order
                    .group(by: \.customerID)
                    .select { ($0.customerID, $0.amount.min()) }
            ) {
                """
                SELECT "orders"."customerID", min("orders"."amount")
                FROM "orders"
                GROUP BY "orders"."customerID"
                """
            }
        }

        @Test
        func `Min with ORDER BY the min`() async {
            await assertSQL(
                of:
                    Order
                    .group(by: \.customerID)
                    .order { $0.amount.min().desc() }
                    .select { ($0.customerID, $0.amount.min()) }
            ) {
                """
                SELECT "orders"."customerID", min("orders"."amount")
                FROM "orders"
                GROUP BY "orders"."customerID"
                ORDER BY min("orders"."amount") DESC
                """
            }
        }

        @Test
        func `Min with HAVING clause`() async {
            await assertSQL(
                of:
                    Order
                    .group(by: \.customerID)
                    .select { ($0.customerID, $0.amount.min()) }
                    .having { $0.amount.min() > 100.0 }
            ) {
                """
                SELECT "orders"."customerID", min("orders"."amount")
                FROM "orders"
                GROUP BY "orders"."customerID"
                HAVING (min("orders"."amount")) > (100.0)
                """
            }
        }

        @Test
        func `Min with HAVING and WHERE`() async {
            await assertSQL(
                of:
                    Order
                    .where { $0.isPaid }
                    .group(by: \.customerID)
                    .select { ($0.customerID, $0.amount.min()) }
                    .having { $0.amount.min() > 50.0 }
            ) {
                """
                SELECT "orders"."customerID", min("orders"."amount")
                FROM "orders"
                WHERE "orders"."isPaid"
                GROUP BY "orders"."customerID"
                HAVING (min("orders"."amount")) > (50.0)
                """
            }
        }

        @Test
        func `Min with HAVING using different operators`() async {

            await assertSQL(
                of:
                    Order
                    .group(by: \.customerID)
                    .select { ($0.customerID, $0.amount.min()) }
                    .having { $0.amount.min() < 100.0 }
            ) {
                """
                SELECT "orders"."customerID", min("orders"."amount")
                FROM "orders"
                GROUP BY "orders"."customerID"
                HAVING (min("orders"."amount")) < (100.0)
                """
            }

            await assertSQL(
                of:
                    Order
                    .group(by: \.customerID)
                    .select { ($0.customerID, $0.amount.min()) }
                    .having { $0.amount.min() >= 25.0 }
            ) {
                """
                SELECT "orders"."customerID", min("orders"."amount")
                FROM "orders"
                GROUP BY "orders"."customerID"
                HAVING (min("orders"."amount")) >= (25.0)
                """
            }

            await assertSQL(
                of:
                    Order
                    .group(by: \.customerID)
                    .select { ($0.customerID, $0.amount.min()) }
                    .having { $0.amount.min() <= 500.0 }
            ) {
                """
                SELECT "orders"."customerID", min("orders"."amount")
                FROM "orders"
                GROUP BY "orders"."customerID"
                HAVING (min("orders"."amount")) <= (500.0)
                """
            }
        }

        @Test
        func `Min with multiple GROUP BY columns`() async {
            await assertSQL(
                of:
                    Order
                    .group(by: \.customerID)
                    .group(by: \.isPaid)
                    .select { ($0.customerID, $0.isPaid, $0.amount.min()) }
            ) {
                """
                SELECT "orders"."customerID", "orders"."isPaid", min("orders"."amount")
                FROM "orders"
                GROUP BY "orders"."customerID", "orders"."isPaid"
                """
            }
        }

        @Test
        func `Min of earliest date per group`() async {
            await assertSQL(
                of:
                    Order
                    .group(by: \.customerID)
                    .select { ($0.customerID, $0.createdAt.min()) }
            ) {
                """
                SELECT "orders"."customerID", min("orders"."createdAt")
                FROM "orders"
                GROUP BY "orders"."customerID"
                """
            }
        }
    }
}
