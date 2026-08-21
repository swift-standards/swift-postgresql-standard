import Foundation
import PostgreSQL_Standard
import PostgreSQL_Standard_Test_Support
import Testing
import Tests_Inline_Snapshot

extension SnapshotTests {
    @Suite struct MaxTests {

        @Test
        func `Table.max with closure syntax`() async {
            await assertSQL(of: Order.max { $0.amount }) {
                """
                SELECT max("orders"."amount")
                FROM "orders"
                """
            }
        }

        @Test
        func `Table.max with KeyPath syntax`() async {
            await assertSQL(of: Order.max(of: \.amount)) {
                """
                SELECT max("orders"."amount")
                FROM "orders"
                """
            }
        }

        @Test
        func `Table.max with filter using closure`() async {
            await assertSQL(of: Order.max(of: { $0.amount }, filter: { $0.isPaid })) {
                """
                SELECT max("orders"."amount") FILTER (WHERE "orders"."isPaid")
                FROM "orders"
                """
            }
        }

        @Test
        func `Table.max with filter using KeyPath`() async {
            await assertSQL(of: Order.max(of: \.amount, filter: { $0.isPaid })) {
                """
                SELECT max("orders"."amount") FILTER (WHERE "orders"."isPaid")
                FROM "orders"
                """
            }
        }

        @Test
        func `Table.max with Double column`() async {
            await assertSQL(of: Order.max { $0.unitPrice }) {
                """
                SELECT max("orders"."unitPrice")
                FROM "orders"
                """
            }
        }

        @Test
        func `Table.max with Int column`() async {
            await assertSQL(of: Order.max { $0.customerID }) {
                """
                SELECT max("orders"."customerID")
                FROM "orders"
                """
            }
        }

        @Test
        func `Table.max with Date column`() async {
            await assertSQL(of: Order.max { $0.createdAt }) {
                """
                SELECT max("orders"."createdAt")
                FROM "orders"
                """
            }
        }

        @Test
        func `Where.max with closure syntax`() async {
            await assertSQL(of: Order.where({ $0.isPaid }).max { $0.amount }) {
                """
                SELECT max("orders"."amount")
                FROM "orders"
                WHERE "orders"."isPaid"
                """
            }
        }

        @Test
        func `Where.max with KeyPath syntax`() async {
            await assertSQL(of: Order.where(\.isPaid).max(of: \.amount)) {
                """
                SELECT max("orders"."amount")
                FROM "orders"
                WHERE "orders"."isPaid"
                """
            }
        }

        @Test
        func `Where.max with complex WHERE clause`() async {
            await assertSQL(
                of:
                    Order
                    .where { $0.isPaid && $0.amount > 100 }
                    .max { $0.amount }
            ) {
                """
                SELECT max("orders"."amount")
                FROM "orders"
                WHERE ("orders"."isPaid") AND ("orders"."amount") > (100.0)
                """
            }
        }

        @Test
        func `Where.max with filter clause`() async {
            await assertSQL(
                of:
                    Order
                    .where { $0.createdAt > Date(timeIntervalSince1970: 0) }
                    .max(of: \.amount, filter: { $0.isPaid })
            ) {
                """
                SELECT max("orders"."amount") FILTER (WHERE "orders"."isPaid")
                FROM "orders"
                WHERE ("orders"."createdAt") > ('1970-01-01 00:00:00.000')
                """
            }
        }

        @Test
        func `Select.max using low-level API`() async {
            await assertSQL(of: Order.select { $0.amount.max() }) {
                """
                SELECT max("orders"."amount")
                FROM "orders"
                """
            }
        }

        @Test
        func `Select.max appending to existing columns using low-level`() async {
            await assertSQL(of: Order.select { ($0.orderID, $0.amount.max()) }) {
                """
                SELECT "orders"."orderID", max("orders"."amount")
                FROM "orders"
                """
            }
        }

        @Test
        func `Select.max with join using low-level API`() async {
            await assertSQL(
                of:
                    Order
                    .join(Customer.all) { $0.customerID.eq($1.id) }
                    .select { order, _ in order.amount.max() }
            ) {
                """
                SELECT max("orders"."amount")
                FROM "orders"
                JOIN "customers" ON ("orders"."customerID") = ("customers"."id")
                """
            }
        }

        @Test
        func `Select.max with join and existing columns using low-level`() async {
            await assertSQL(
                of:
                    Order
                    .join(Customer.all) { $0.customerID.eq($1.id) }
                    .select { ($1.name, $0.amount.max()) }
            ) {
                """
                SELECT "customers"."name", max("orders"."amount")
                FROM "orders"
                JOIN "customers" ON ("orders"."customerID") = ("customers"."id")
                """
            }
        }

        @Test
        func `Select.max accessing joined table columns using low-level`() async {
            await assertSQL(
                of:
                    Order
                    .join(LineItem.all) { $0.orderID.eq($1.orderID) }
                    .select { _, lineItem in lineItem.price.max() }
            ) {
                """
                SELECT max("lineItems"."price")
                FROM "orders"
                JOIN "lineItems" ON ("orders"."orderID") = ("lineItems"."orderID")
                """
            }
        }

        @Test
        func `Max of nullable column returns single optional`() async {

            await assertSQL(of: Order.max { $0.discount }) {
                """
                SELECT max("orders"."discount")
                FROM "orders"
                """
            }
        }

        @Test
        func `Max of calculated expression`() async {
            await assertSQL(of: Order.max { $0.quantity * $0.unitPrice }) {
                """
                SELECT max(("orders"."quantity") * ("orders"."unitPrice"))
                FROM "orders"
                """
            }
        }

        @Test
        func `Multiple aggregates including max in one query`() async {
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

            let _: Structured_Queries_Primitives.Select<Double?, Order, ()> = Order.max {
                $0.amount
            }
            let _: Structured_Queries_Primitives.Select<Double?, Order, ()> = Order.max(
                of: \.amount
            )

            let _: Structured_Queries_Primitives.Select<Double?, Order, ()> = Order.where {
                $0.isPaid
            }.max {
                $0.amount
            }
            let _: Structured_Queries_Primitives.Select<Double?, Order, ()> = Order.where {
                $0.isPaid
            }.max(
                of: \.amount
            )

            let _: Structured_Queries_Primitives.Select<Int?, Order, ()> = Order.max {
                $0.customerID
            }

            let _: Structured_Queries_Primitives.Select<Date?, Order, ()> = Order.max {
                $0.createdAt
            }

            let _: Structured_Queries_Primitives.Select<Double?, Order, ()> = Order.max {
                $0.discount
            }

            let _: Structured_Queries_Primitives.Select<Double?, Order, ()> = Order.max {
                $0.quantity * $0.unitPrice
            }
        }

        @Test
        func `Max with GROUP BY`() async {
            await assertSQL(
                of:
                    Order
                    .group(by: \.customerID)
                    .select { ($0.customerID, $0.amount.max()) }
            ) {
                """
                SELECT "orders"."customerID", max("orders"."amount")
                FROM "orders"
                GROUP BY "orders"."customerID"
                """
            }
        }

        @Test
        func `Max with ORDER BY the max`() async {
            await assertSQL(
                of:
                    Order
                    .group(by: \.customerID)
                    .order { $0.amount.max().desc() }
                    .select { ($0.customerID, $0.amount.max()) }
            ) {
                """
                SELECT "orders"."customerID", max("orders"."amount")
                FROM "orders"
                GROUP BY "orders"."customerID"
                ORDER BY max("orders"."amount") DESC
                """
            }
        }

        @Test
        func `Max with HAVING clause`() async {
            await assertSQL(
                of:
                    Order
                    .group(by: \.customerID)
                    .select { ($0.customerID, $0.amount.max()) }
                    .having { $0.amount.max() > 1000.0 }
            ) {
                """
                SELECT "orders"."customerID", max("orders"."amount")
                FROM "orders"
                GROUP BY "orders"."customerID"
                HAVING (max("orders"."amount")) > (1000.0)
                """
            }
        }

        @Test
        func `Max with HAVING and WHERE`() async {
            await assertSQL(
                of:
                    Order
                    .where { $0.isPaid }
                    .group(by: \.customerID)
                    .select { ($0.customerID, $0.amount.max()) }
                    .having { $0.amount.max() > 500.0 }
            ) {
                """
                SELECT "orders"."customerID", max("orders"."amount")
                FROM "orders"
                WHERE "orders"."isPaid"
                GROUP BY "orders"."customerID"
                HAVING (max("orders"."amount")) > (500.0)
                """
            }
        }

        @Test
        func `Max with HAVING using different operators`() async {

            await assertSQL(
                of:
                    Order
                    .group(by: \.customerID)
                    .select { ($0.customerID, $0.amount.max()) }
                    .having { $0.amount.max() < 1000.0 }
            ) {
                """
                SELECT "orders"."customerID", max("orders"."amount")
                FROM "orders"
                GROUP BY "orders"."customerID"
                HAVING (max("orders"."amount")) < (1000.0)
                """
            }

            await assertSQL(
                of:
                    Order
                    .group(by: \.customerID)
                    .select { ($0.customerID, $0.amount.max()) }
                    .having { $0.amount.max() >= 250.0 }
            ) {
                """
                SELECT "orders"."customerID", max("orders"."amount")
                FROM "orders"
                GROUP BY "orders"."customerID"
                HAVING (max("orders"."amount")) >= (250.0)
                """
            }

            await assertSQL(
                of:
                    Order
                    .group(by: \.customerID)
                    .select { ($0.customerID, $0.amount.max()) }
                    .having { $0.amount.max() <= 5000.0 }
            ) {
                """
                SELECT "orders"."customerID", max("orders"."amount")
                FROM "orders"
                GROUP BY "orders"."customerID"
                HAVING (max("orders"."amount")) <= (5000.0)
                """
            }
        }

        @Test
        func `Max with multiple GROUP BY columns`() async {
            await assertSQL(
                of:
                    Order
                    .group(by: \.customerID)
                    .group(by: \.isPaid)
                    .select { ($0.customerID, $0.isPaid, $0.amount.max()) }
            ) {
                """
                SELECT "orders"."customerID", "orders"."isPaid", max("orders"."amount")
                FROM "orders"
                GROUP BY "orders"."customerID", "orders"."isPaid"
                """
            }
        }

        @Test
        func `Max of latest date per group`() async {
            await assertSQL(
                of:
                    Order
                    .group(by: \.customerID)
                    .select { ($0.customerID, $0.createdAt.max()) }
            ) {
                """
                SELECT "orders"."customerID", max("orders"."createdAt")
                FROM "orders"
                GROUP BY "orders"."customerID"
                """
            }
        }
    }
}
