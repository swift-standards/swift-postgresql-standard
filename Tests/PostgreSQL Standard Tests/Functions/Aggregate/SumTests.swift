import Foundation
import PostgreSQL_Standard
import PostgreSQL_Standard_Test_Support
import Testing
import Tests_Inline_Snapshot

extension SnapshotTests {
    @Suite struct SumTests {

        @Test
        func `Table.sum with closure syntax`() async {
            await assertSQL(of: Order.sum { $0.amount }) {
                """
                SELECT SUM("orders"."amount")
                FROM "orders"
                """
            }
        }

        @Test
        func `Table.sum with KeyPath syntax`() async {
            await assertSQL(of: Order.sum(of: \.amount)) {
                """
                SELECT SUM("orders"."amount")
                FROM "orders"
                """
            }
        }

        @Test
        func `Table.sum with filter using closure`() async {
            await assertSQL(of: Order.sum(of: { $0.amount }, filter: { $0.isPaid })) {
                """
                SELECT SUM("orders"."amount") FILTER (WHERE "orders"."isPaid")
                FROM "orders"
                """
            }
        }

        @Test
        func `Table.sum with filter using KeyPath`() async {
            await assertSQL(of: Order.sum(of: \.amount, filter: { $0.isPaid })) {
                """
                SELECT SUM("orders"."amount") FILTER (WHERE "orders"."isPaid")
                FROM "orders"
                """
            }
        }

        @Test
        func `Table.sum with Double column`() async {
            await assertSQL(of: Order.sum { $0.unitPrice }) {
                """
                SELECT SUM("orders"."unitPrice")
                FROM "orders"
                """
            }
        }

        @Test
        func `Where.sum with closure syntax`() async {
            await assertSQL(of: Order.where({ $0.isPaid }).sum { $0.amount }) {
                """
                SELECT SUM("orders"."amount")
                FROM "orders"
                WHERE "orders"."isPaid"
                """
            }
        }

        @Test
        func `Where.sum with KeyPath syntax`() async {
            await assertSQL(of: Order.where(\.isPaid).sum(of: \.amount)) {
                """
                SELECT SUM("orders"."amount")
                FROM "orders"
                WHERE "orders"."isPaid"
                """
            }
        }

        @Test
        func `Where.sum with complex WHERE clause`() async {
            await assertSQL(
                of:
                    Order
                    .where { $0.isPaid && $0.amount > 100 }
                    .sum { $0.amount }
            ) {
                """
                SELECT SUM("orders"."amount")
                FROM "orders"
                WHERE ("orders"."isPaid") AND ("orders"."amount") > (100.0)
                """
            }
        }

        @Test
        func `Where.sum with filter clause`() async {
            await assertSQL(
                of:
                    Order
                    .where { $0.createdAt > Date(timeIntervalSince1970: 0) }
                    .sum(of: \.amount, filter: { $0.isPaid })
            ) {
                """
                SELECT SUM("orders"."amount") FILTER (WHERE "orders"."isPaid")
                FROM "orders"
                WHERE ("orders"."createdAt") > ('1970-01-01 00:00:00.000')
                """
            }
        }

        @Test
        func `Select.sum using low-level API`() async {
            await assertSQL(of: Order.select { $0.amount.sum() }) {
                """
                SELECT SUM("orders"."amount")
                FROM "orders"
                """
            }
        }

        @Test
        func `Select.sum appending to existing columns using low-level`() async {
            await assertSQL(of: Order.select { ($0.orderID, $0.amount.sum()) }) {
                """
                SELECT "orders"."orderID", SUM("orders"."amount")
                FROM "orders"
                """
            }
        }

        @Test
        func `Select.sum with join using low-level API`() async {
            await assertSQL(
                of:
                    Order
                    .join(Customer.all) { $0.customerID.eq($1.id) }
                    .select { order, _ in order.amount.sum() }
            ) {
                """
                SELECT SUM("orders"."amount")
                FROM "orders"
                JOIN "customers" ON ("orders"."customerID") = ("customers"."id")
                """
            }
        }

        @Test
        func `Select.sum with join and existing columns using low-level`() async {
            await assertSQL(
                of:
                    Order
                    .join(Customer.all) { $0.customerID.eq($1.id) }
                    .select { ($1.name, $0.amount.sum()) }
            ) {
                """
                SELECT "customers"."name", SUM("orders"."amount")
                FROM "orders"
                JOIN "customers" ON ("orders"."customerID") = ("customers"."id")
                """
            }
        }

        @Test
        func `Select.sum accessing joined table columns using low-level`() async {
            await assertSQL(
                of:
                    Order
                    .join(LineItem.all) { $0.orderID.eq($1.orderID) }
                    .select { _, lineItem in (lineItem.price * lineItem.quantity).sum() }
            ) {
                """
                SELECT SUM(("lineItems"."price") * ("lineItems"."quantity"))
                FROM "orders"
                JOIN "lineItems" ON ("orders"."orderID") = ("lineItems"."orderID")
                """
            }
        }

        @Test
        func `Sum of nullable column returns single optional`() async {

            await assertSQL(of: Order.sum { $0.discount }) {
                """
                SELECT SUM("orders"."discount")
                FROM "orders"
                """
            }
        }

        @Test
        func `Sum with DISTINCT`() async {
            await assertSQL(of: Order.select { $0.amount.sum(distinct: true) }) {
                """
                SELECT SUM(DISTINCT "orders"."amount")
                FROM "orders"
                """
            }
        }

        @Test
        func `Sum of calculated expression`() async {
            await assertSQL(of: Order.sum { $0.quantity * $0.unitPrice }) {
                """
                SELECT SUM(("orders"."quantity") * ("orders"."unitPrice"))
                FROM "orders"
                """
            }
        }

        @Test
        func `Multiple aggregates in one query`() async {
            await assertSQL(
                of: Order.select { ($0.amount.sum(), $0.quantity.sum()) }
            ) {
                """
                SELECT SUM("orders"."amount"), SUM("orders"."quantity")
                FROM "orders"
                """
            }
        }

        func compileTimeTypeTests() {

            let _: Structured_Queries.Select<Double?, Order, ()> = Order.sum {
                $0.amount
            }
            let _: Structured_Queries.Select<Double?, Order, ()> = Order.sum(
                of: \.amount
            )

            let _: Structured_Queries.Select<Double?, Order, ()> = Order.where {
                $0.isPaid
            }.sum {
                $0.amount
            }
            let _: Structured_Queries.Select<Double?, Order, ()> = Order.where {
                $0.isPaid
            }.sum(
                of: \.amount
            )

            let _: Structured_Queries.Select<Double?, Order, ()> = Order.sum {
                $0.quantity
            }

            let _: Structured_Queries.Select<Double?, Order, ()> = Order.sum {
                $0.discount
            }

            let _: Structured_Queries.Select<Double?, Order, ()> = Order.sum {
                $0.quantity * $0.unitPrice
            }
        }

        @Test
        func `Sum with GROUP BY`() async {
            await assertSQL(
                of:
                    Order
                    .group(by: \.customerID)
                    .select { ($0.customerID, $0.amount.sum()) }
            ) {
                """
                SELECT "orders"."customerID", SUM("orders"."amount")
                FROM "orders"
                GROUP BY "orders"."customerID"
                """
            }
        }

        @Test
        func `Sum with HAVING`() async {
            await assertSQL(
                of:
                    Order
                    .group(by: \.customerID)
                    .select { ($0.customerID, $0.amount.sum()) }
            ) {
                """
                SELECT "orders"."customerID", SUM("orders"."amount")
                FROM "orders"
                GROUP BY "orders"."customerID"
                """
            }
        }

        @Test
        func `Sum with ORDER BY the sum`() async {
            await assertSQL(
                of:
                    Order
                    .group(by: \.customerID)
                    .order { $0.amount.sum().desc() }
                    .select { ($0.customerID, $0.amount.sum()) }
            ) {
                """
                SELECT "orders"."customerID", SUM("orders"."amount")
                FROM "orders"
                GROUP BY "orders"."customerID"
                ORDER BY SUM("orders"."amount") DESC
                """
            }
        }

        @Test
        func `Sum with HAVING clause`() async {
            await assertSQL(
                of:
                    Order
                    .group(by: \.customerID)
                    .select { ($0.customerID, $0.amount.sum()) }
                    .having { $0.amount.sum() > 1000.0 }
            ) {
                """
                SELECT "orders"."customerID", SUM("orders"."amount")
                FROM "orders"
                GROUP BY "orders"."customerID"
                HAVING (SUM("orders"."amount")) > (1000.0)
                """
            }
        }

        @Test
        func `Sum with HAVING and WHERE`() async {
            await assertSQL(
                of:
                    Order
                    .where { $0.isPaid }
                    .group(by: \.customerID)
                    .select { ($0.customerID, $0.amount.sum()) }
                    .having { $0.amount.sum() > 500.0 }
            ) {
                """
                SELECT "orders"."customerID", SUM("orders"."amount")
                FROM "orders"
                WHERE "orders"."isPaid"
                GROUP BY "orders"."customerID"
                HAVING (SUM("orders"."amount")) > (500.0)
                """
            }
        }

        @Test
        func `Sum with HAVING using different operators`() async {

            await assertSQL(
                of:
                    Order
                    .group(by: \.customerID)
                    .select { ($0.customerID, $0.amount.sum()) }
                    .having { $0.amount.sum() < 100.0 }
            ) {
                """
                SELECT "orders"."customerID", SUM("orders"."amount")
                FROM "orders"
                GROUP BY "orders"."customerID"
                HAVING (SUM("orders"."amount")) < (100.0)
                """
            }

            await assertSQL(
                of:
                    Order
                    .group(by: \.customerID)
                    .select { ($0.customerID, $0.amount.sum()) }
                    .having { $0.amount.sum() >= 250.0 }
            ) {
                """
                SELECT "orders"."customerID", SUM("orders"."amount")
                FROM "orders"
                GROUP BY "orders"."customerID"
                HAVING (SUM("orders"."amount")) >= (250.0)
                """
            }

            await assertSQL(
                of:
                    Order
                    .group(by: \.customerID)
                    .select { ($0.customerID, $0.amount.sum()) }
                    .having { $0.amount.sum() <= 5000.0 }
            ) {
                """
                SELECT "orders"."customerID", SUM("orders"."amount")
                FROM "orders"
                GROUP BY "orders"."customerID"
                HAVING (SUM("orders"."amount")) <= (5000.0)
                """
            }
        }
    }
}
