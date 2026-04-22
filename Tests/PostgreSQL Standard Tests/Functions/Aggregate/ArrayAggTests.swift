import Foundation
import Tests_Inline_Snapshot
import PostgreSQL_Standard
import PostgreSQL_Standard_Test_Support
import Testing

extension SnapshotTests {
    @Suite struct ArrayAggTests {
        // MARK: - Table.arrayAgg Tests

        @Test
        func `Table.arrayAgg with closure syntax`() async {
            await assertSQL(of: Customer.arrayAgg { $0.name }) {
                """
                SELECT array_agg("customers"."name")
                FROM "customers"
                """
            }
        }

        @Test
        func `Table.arrayAgg with filter using closure`() async {
            await assertSQL(of: Order.arrayAgg(of: { $0.orderID }, filter: { $0.isPaid })) {
                """
                SELECT array_agg("orders"."orderID") FILTER (WHERE "orders"."isPaid")
                FROM "orders"
                """
            }
        }

        @Test
        func `Table.arrayAgg with Int column`() async {
            await assertSQL(of: Customer.arrayAgg { $0.id }) {
                """
                SELECT array_agg("customers"."id")
                FROM "customers"
                """
            }
        }

        @Test
        func `Table.arrayAgg with Date column`() async {
            await assertSQL(of: Order.arrayAgg { $0.createdAt }) {
                """
                SELECT array_agg("orders"."createdAt")
                FROM "orders"
                """
            }
        }

        // MARK: - Where.arrayAgg Tests

        @Test
        func `Where.arrayAgg with closure syntax`() async {
            await assertSQL(of: Order.where { $0.isPaid }.arrayAgg { $0.orderID }) {
                """
                SELECT array_agg("orders"."orderID")
                FROM "orders"
                WHERE "orders"."isPaid"
                """
            }
        }

        @Test
        func `Where.arrayAgg with complex WHERE clause`() async {
            await assertSQL(
                of:
                    Order
                    .where { $0.isPaid && $0.amount > 100 }
                    .arrayAgg { $0.orderID }
            ) {
                """
                SELECT array_agg("orders"."orderID")
                FROM "orders"
                WHERE ("orders"."isPaid") AND ("orders"."amount") > (100.0)
                """
            }
        }

        @Test
        func `Where.arrayAgg with filter clause`() async {
            await assertSQL(
                of:
                    Order
                    .where { $0.createdAt > Date(timeIntervalSince1970: 0) }
                    .arrayAgg(of: { $0.orderID }, filter: { $0.isPaid })
            ) {
                """
                SELECT array_agg("orders"."orderID") FILTER (WHERE "orders"."isPaid")
                FROM "orders"
                WHERE ("orders"."createdAt") > ('1970-01-01 00:00:00.000')
                """
            }
        }

        // MARK: - Select.arrayAgg Tests (Low-Level API)

        @Test
        func `Select.arrayAgg using low-level API`() async {
            await assertSQL(of: Customer.select { $0.name.arrayAgg() }) {
                """
                SELECT array_agg("customers"."name")
                FROM "customers"
                """
            }
        }

        @Test
        func `Select.arrayAgg appending to existing columns`() async {
            await assertSQL(of: Customer.select { ($0.id, $0.name.arrayAgg()) }) {
                """
                SELECT "customers"."id", array_agg("customers"."name")
                FROM "customers"
                """
            }
        }

        @Test
        func `Select.arrayAgg with join using low-level API`() async {
            await assertSQL(
                of:
                    Order
                    .join(Customer.all) { $0.customerID.eq($1.id) }
                    .select { order, _ in order.orderID.arrayAgg() }
            ) {
                """
                SELECT array_agg("orders"."orderID")
                FROM "orders"
                JOIN "customers" ON ("orders"."customerID") = ("customers"."id")
                """
            }
        }

        @Test
        func `Select.arrayAgg with distinct`() async {
            await assertSQL(of: Customer.select { $0.name.arrayAgg(distinct: true) }) {
                """
                SELECT array_agg(DISTINCT "customers"."name")
                FROM "customers"
                """
            }
        }

        @Test
        func `Select.arrayAgg with filter`() async {
            await assertSQL(
                of: Order.select { $0.orderID.arrayAgg(filter: $0.isPaid) }
            ) {
                """
                SELECT array_agg("orders"."orderID") FILTER (WHERE "orders"."isPaid")
                FROM "orders"
                """
            }
        }

        // MARK: - Complex Expression Tests

        @Test
        func `ArrayAgg of calculated expression`() async {
            await assertSQL(of: Order.select { ($0.quantity * $0.unitPrice).arrayAgg() }) {
                """
                SELECT array_agg(("orders"."quantity") * ("orders"."unitPrice"))
                FROM "orders"
                """
            }
        }

        // MARK: - Compile-Time Type Tests

        func compileTimeTypeTests() {
            // Verify return types compile correctly

            // Table.arrayAgg returns Select<String?, Customer, ()>
            let _: Select<String?, Customer, ()> = Customer.arrayAgg { $0.name }

            // Where.arrayAgg returns Select<String?, Order, ()>
            let _: Select<String?, Order, ()> = Order.where { $0.isPaid }.arrayAgg { $0.orderID }

            // Int column returns String? (array serialized as string)
            let _: Select<String?, Customer, ()> = Customer.arrayAgg { $0.id }
        }

        // MARK: - Edge Cases

        @Test
        func `ArrayAgg with GROUP BY`() async {
            await assertSQL(
                of:
                    Order
                    .group(by: \.customerID)
                    .select { ($0.customerID, $0.orderID.arrayAgg()) }
            ) {
                """
                SELECT "orders"."customerID", array_agg("orders"."orderID")
                FROM "orders"
                GROUP BY "orders"."customerID"
                """
            }
        }

        @Test
        func `ArrayAgg with ORDER BY`() async {
            await assertSQL(
                of:
                    Customer
                    .select { $0.name.arrayAgg(order: $0.name.asc()) }
            ) {
                """
                SELECT array_agg("customers"."name" ORDER BY "customers"."name" ASC)
                FROM "customers"
                """
            }
        }

        @Test
        func `ArrayAgg with HAVING clause`() async {
            await assertSQL(
                of:
                    Order
                    .group(by: \.customerID)
                    .select { ($0.customerID, $0.orderID.arrayAgg()) }
                    .having { $0.orderID.count() > 1 }
            ) {
                """
                SELECT "orders"."customerID", array_agg("orders"."orderID")
                FROM "orders"
                GROUP BY "orders"."customerID"
                HAVING (count("orders"."orderID")) > (1)
                """
            }
        }

        @Test
        func `ArrayAgg with multiple GROUP BY columns`() async {
            await assertSQL(
                of:
                    Order
                    .group(by: \.customerID)
                    .group(by: \.isPaid)
                    .select { ($0.customerID, $0.isPaid, $0.orderID.arrayAgg()) }
            ) {
                """
                SELECT "orders"."customerID", "orders"."isPaid", array_agg("orders"."orderID")
                FROM "orders"
                GROUP BY "orders"."customerID", "orders"."isPaid"
                """
            }
        }

        @Test
        func `ArrayAgg with distinct and order`() async {
            await assertSQL(
                of: Customer.select { $0.name.arrayAgg(distinct: true, order: $0.name.desc()) }
            ) {
                """
                SELECT array_agg(DISTINCT "customers"."name" ORDER BY "customers"."name" DESC)
                FROM "customers"
                """
            }
        }

        @Test
        func `ArrayAgg with distinct and filter`() async {
            await assertSQL(
                of: Order.select { $0.orderID.arrayAgg(distinct: true, filter: $0.isPaid) }
            ) {
                """
                SELECT array_agg(DISTINCT "orders"."orderID") FILTER (WHERE "orders"."isPaid")
                FROM "orders"
                """
            }
        }

        @Test
        func `Multiple aggregates including arrayAgg`() async {
            await assertSQL(
                of: Customer.select { ($0.id.count(), $0.name.arrayAgg()) }
            ) {
                """
                SELECT count("customers"."id"), array_agg("customers"."name")
                FROM "customers"
                """
            }
        }

        @Test
        func `ArrayAgg of nullable column`() async {
            await assertSQL(of: Order.arrayAgg { $0.discount }) {
                """
                SELECT array_agg("orders"."discount")
                FROM "orders"
                """
            }
        }
    }
}
