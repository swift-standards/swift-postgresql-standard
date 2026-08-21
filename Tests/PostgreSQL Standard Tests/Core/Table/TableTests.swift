import Foundation
import PostgreSQL_Standard
import PostgreSQL_Standard_Macros
import PostgreSQL_Standard_Test_Support
import Testing
import Tests_Inline_Snapshot

extension SnapshotTests {
    @Suite struct TableTests {

        @Table
        struct SoftDeleteRow {
            static let all = unscoped.where { !$0.isDeleted }.order { $0.id.desc() }
            let id: Int
            var isDeleted = false
        }

        @Test func defaultScopeAppliesWhereClause() async {

            await assertSQL(of: SoftDeleteRow.where { $0.id > 0 }) {
                """
                SELECT "softDeleteRows"."id", "softDeleteRows"."isDeleted"
                FROM "softDeleteRows"
                WHERE NOT ("softDeleteRows"."isDeleted") AND ("softDeleteRows"."id") > (0)
                ORDER BY "softDeleteRows"."id" DESC
                """
            }
        }

        @Test func unscopedRemovesDefaultScope() async {

            await assertSQL(of: SoftDeleteRow.unscoped) {
                """
                SELECT "softDeleteRows"."id", "softDeleteRows"."isDeleted"
                FROM "softDeleteRows"
                """
            }
        }

        @Test func defaultScopeWithTableAlias() async {
            enum R: AliasName {}

            await assertSQL(of: SoftDeleteRow.as(R.self).select(\.id)) {
                """
                SELECT "rs"."id"
                FROM "softDeleteRows" AS "rs"
                WHERE NOT ("rs"."isDeleted")
                ORDER BY "rs"."id" DESC
                """
            }

            await assertSQL(of: SoftDeleteRow.as(R.self).unscoped.select(\.id)) {
                """
                SELECT "rs"."id"
                FROM "softDeleteRows" AS "rs"
                """
            }
        }

        @Test func defaultScopeInDeleteStatements() async {

            await assertSQL(
                of:
                    SoftDeleteRow
                    .where { $0.id > 0 }
                    .delete()
                    .returning(\.self)
            ) {
                """
                DELETE FROM "softDeleteRows"
                WHERE NOT ("softDeleteRows"."isDeleted") AND ("softDeleteRows"."id") > (0)
                RETURNING "id", "isDeleted"
                """
            }

            await assertSQL(
                of: SoftDeleteRow
                    .unscoped
                    .where { $0.id > 0 }
                    .delete()
                    .returning(\.self)
            ) {
                """
                DELETE FROM "softDeleteRows"
                WHERE ("softDeleteRows"."id") > (0)
                RETURNING "id", "isDeleted"
                """
            }
        }

        @Test func defaultScopeInUpdateStatements() async {

            await assertSQL(
                of:
                    SoftDeleteRow
                    .update { $0.isDeleted.toggle() }
                    .where { $0.id > 0 }
                    .returning(\.self)
            ) {
                """
                UPDATE "softDeleteRows"
                SET "isDeleted" = NOT ("softDeleteRows"."isDeleted")
                WHERE NOT ("softDeleteRows"."isDeleted") AND ("softDeleteRows"."id") > (0)
                RETURNING "softDeleteRows"."id", "softDeleteRows"."isDeleted"
                """
            }

            await assertSQL(
                of: SoftDeleteRow
                    .unscoped
                    .where { $0.id > 0 }
                    .update { $0.isDeleted.toggle() }
                    .returning(\.self)
            ) {
                """
                UPDATE "softDeleteRows"
                SET "isDeleted" = NOT ("softDeleteRows"."isDeleted")
                WHERE ("softDeleteRows"."id") > (0)
                RETURNING "softDeleteRows"."id", "softDeleteRows"."isDeleted"
                """
            }
        }
    }
}
