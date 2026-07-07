import Foundation
import PostgreSQL_Standard
import PostgreSQL_Standard_Test_Support
import Testing
import Tests_Inline_Snapshot

extension SnapshotTests {
    @Suite struct JsonbAggTests {
        // MARK: - Table.jsonbAgg Tests

        @Test
        func `Table.jsonbAgg with closure syntax`() async {
            await assertSQL(of: Customer.jsonbAgg { $0.name }) {
                """
                SELECT JSONB_AGG("customers"."name")
                FROM "customers"
                """
            }
        }

        @Test
        func `Table.jsonbAgg with filter using closure`() async {
            await assertSQL(of: Order.jsonbAgg(of: { $0.orderID }, filter: { $0.isPaid })) {
                """
                SELECT JSONB_AGG("orders"."orderID") FILTER (WHERE "orders"."isPaid")
                FROM "orders"
                """
            }
        }

        @Test
        func `Table.jsonbAgg with Int column`() async {
            await assertSQL(of: Customer.jsonbAgg { $0.id }) {
                """
                SELECT JSONB_AGG("customers"."id")
                FROM "customers"
                """
            }
        }

        @Test
        func `Table.jsonbAgg with Date column`() async {
            await assertSQL(of: Order.jsonbAgg { $0.createdAt }) {
                """
                SELECT JSONB_AGG("orders"."createdAt")
                FROM "orders"
                """
            }
        }

        // MARK: - Where.jsonbAgg Tests

        @Test
        func `Where.jsonbAgg with closure syntax`() async {
            await assertSQL(of: Order.where { $0.isPaid }.jsonbAgg { $0.orderID }) {
                """
                SELECT JSONB_AGG("orders"."orderID")
                FROM "orders"
                WHERE "orders"."isPaid"
                """
            }
        }

        @Test
        func `Where.jsonbAgg with complex WHERE clause`() async {
            await assertSQL(
                of:
                    Order
                    .where { $0.isPaid && $0.amount > 100 }
                    .jsonbAgg { $0.orderID }
            ) {
                """
                SELECT JSONB_AGG("orders"."orderID")
                FROM "orders"
                WHERE ("orders"."isPaid") AND ("orders"."amount") > (100.0)
                """
            }
        }

        @Test
        func `Where.jsonbAgg with filter clause`() async {
            await assertSQL(
                of:
                    Order
                    .where { $0.createdAt > Date(timeIntervalSince1970: 0) }
                    .jsonbAgg(of: { $0.orderID }, filter: { $0.isPaid })
            ) {
                """
                SELECT JSONB_AGG("orders"."orderID") FILTER (WHERE "orders"."isPaid")
                FROM "orders"
                WHERE ("orders"."createdAt") > ('1970-01-01 00:00:00.000')
                """
            }
        }

        // MARK: - Select.jsonbAgg Tests (Low-Level API)

        @Test
        func `Select.jsonbAgg using low-level API`() async {
            await assertSQL(of: Customer.select { $0.name.jsonbAgg() }) {
                """
                SELECT jsonb_agg("customers"."name")
                FROM "customers"
                """
            }
        }

        @Test
        func `Select.jsonbAgg appending to existing columns`() async {
            await assertSQL(of: Customer.select { ($0.id, $0.name.jsonbAgg()) }) {
                """
                SELECT "customers"."id", jsonb_agg("customers"."name")
                FROM "customers"
                """
            }
        }

        @Test
        func `Select.jsonbAgg with join using low-level API`() async {
            await assertSQL(
                of:
                    Order
                    .join(Customer.all) { $0.customerID.eq($1.id) }
                    .select { order, _ in order.orderID.jsonbAgg() }
            ) {
                """
                SELECT jsonb_agg("orders"."orderID")
                FROM "orders"
                JOIN "customers" ON ("orders"."customerID") = ("customers"."id")
                """
            }
        }

        @Test
        func `Select.jsonbAgg with distinct`() async {
            await assertSQL(of: Customer.select { $0.name.jsonbAgg(distinct: true) }) {
                """
                SELECT jsonb_agg(DISTINCT "customers"."name")
                FROM "customers"
                """
            }
        }

        @Test
        func `Select.jsonbAgg with filter`() async {
            await assertSQL(
                of: Order.select { $0.orderID.jsonbAgg(filter: $0.isPaid) }
            ) {
                """
                SELECT jsonb_agg("orders"."orderID") FILTER (WHERE "orders"."isPaid")
                FROM "orders"
                """
            }
        }

        // MARK: - Complex Expression Tests

        @Test
        func `JsonbAgg of calculated expression`() async {
            await assertSQL(of: Order.select { ($0.quantity * $0.unitPrice).jsonbAgg() }) {
                """
                SELECT jsonb_agg(("orders"."quantity") * ("orders"."unitPrice"))
                FROM "orders"
                """
            }
        }

        // MARK: - Compile-Time Type Tests

        func compileTimeTypeTests() {
            // Verify return types compile correctly

            // Table.jsonbAgg returns Select<String?, Customer, ()>
            let _: Select<String?, Customer, ()> = Customer.jsonbAgg { $0.name }

            // Where.jsonbAgg returns Select<String?, Order, ()>
            let _: Select<String?, Order, ()> = Order.where { $0.isPaid }.jsonbAgg { $0.orderID }

            // Int column returns String? (JSONB array serialized as string)
            let _: Select<String?, Customer, ()> = Customer.jsonbAgg { $0.id }
        }

        // MARK: - Edge Cases

        @Test
        func `JsonbAgg with GROUP BY`() async {
            await assertSQL(
                of:
                    Order
                    .group(by: \.customerID)
                    .select { ($0.customerID, $0.orderID.jsonbAgg()) }
            ) {
                """
                SELECT "orders"."customerID", jsonb_agg("orders"."orderID")
                FROM "orders"
                GROUP BY "orders"."customerID"
                """
            }
        }

        @Test
        func `JsonbAgg with ORDER BY`() async {
            await assertSQL(
                of:
                    Customer
                    .select { $0.name.jsonbAgg(order: $0.name.asc()) }
            ) {
                """
                SELECT jsonb_agg("customers"."name" ORDER BY "customers"."name" ASC)
                FROM "customers"
                """
            }
        }

        @Test
        func `JsonbAgg with HAVING clause`() async {
            await assertSQL(
                of:
                    Order
                    .group(by: \.customerID)
                    .select { ($0.customerID, $0.orderID.jsonbAgg()) }
                    .having { $0.orderID.count() > 1 }
            ) {
                """
                SELECT "orders"."customerID", jsonb_agg("orders"."orderID")
                FROM "orders"
                GROUP BY "orders"."customerID"
                HAVING (count("orders"."orderID")) > (1)
                """
            }
        }

        @Test
        func `JsonbAgg with multiple GROUP BY columns`() async {
            await assertSQL(
                of:
                    Order
                    .group(by: \.customerID)
                    .group(by: \.isPaid)
                    .select { ($0.customerID, $0.isPaid, $0.orderID.jsonbAgg()) }
            ) {
                """
                SELECT "orders"."customerID", "orders"."isPaid", jsonb_agg("orders"."orderID")
                FROM "orders"
                GROUP BY "orders"."customerID", "orders"."isPaid"
                """
            }
        }

        @Test
        func `JsonbAgg with distinct and order`() async {
            await assertSQL(
                of: Customer.select { $0.name.jsonbAgg(distinct: true, order: $0.name.desc()) }
            ) {
                """
                SELECT jsonb_agg(DISTINCT "customers"."name" ORDER BY "customers"."name" DESC)
                FROM "customers"
                """
            }
        }

        @Test
        func `JsonbAgg with distinct and filter`() async {
            await assertSQL(
                of: Order.select { $0.orderID.jsonbAgg(distinct: true, filter: $0.isPaid) }
            ) {
                """
                SELECT jsonb_agg(DISTINCT "orders"."orderID") FILTER (WHERE "orders"."isPaid")
                FROM "orders"
                """
            }
        }

        @Test
        func `Multiple aggregates including jsonbAgg`() async {
            await assertSQL(
                of: Customer.select { ($0.id.count(), $0.name.jsonbAgg()) }
            ) {
                """
                SELECT count("customers"."id"), jsonb_agg("customers"."name")
                FROM "customers"
                """
            }
        }

        @Test
        func `JsonbAgg of nullable column`() async {
            await assertSQL(of: Order.jsonbAgg { $0.discount }) {
                """
                SELECT JSONB_AGG("orders"."discount")
                FROM "orders"
                """
            }
        }

        @Test
        func `JsonbAgg vs ArrayAgg comparison in same query`() async {
            await assertSQL(
                of: Customer.select { ($0.name.arrayAgg(), $0.name.jsonbAgg()) }
            ) {
                """
                SELECT array_agg("customers"."name"), jsonb_agg("customers"."name")
                FROM "customers"
                """
            }
        }
    }
}
