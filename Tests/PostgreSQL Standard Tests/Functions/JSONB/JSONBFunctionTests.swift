import Foundation
import PostgreSQL_Standard
import PostgreSQL_Standard_Test_Support
import Testing
import Tests_Inline_Snapshot

extension SnapshotTests.JSONB {
    @Suite("Functions") struct FunctionTests {

        @Test func jsonbPrettyFunction() async {
            let query = TestUser.select { user in
                (user.id, user.settings.prettyFormatted())
            }

            await assertSQL(
                of: query
            ) {
                """
                SELECT "test_users"."id", jsonb_pretty("test_users"."settings")
                FROM "test_users"
                """
            }
        }

        @Test func jsonbTypeOfFunction() async {
            let query = TestUser.select { user in
                (user.id, user.metadata.typeString())
            }

            await assertSQL(
                of: query
            ) {
                """
                SELECT "test_users"."id", jsonb_typeof("test_users"."metadata")
                FROM "test_users"
                """
            }
        }

        @Test func jsonbArrayLengthFunction() async {
            let query = TestUser.select { user in
                (user.id, user.tags.arrayLength())
            }

            await assertSQL(
                of: query
            ) {
                """
                SELECT "test_users"."id", jsonb_array_length("test_users"."tags")
                FROM "test_users"
                """
            }
        }

        @Test func jsonbFunctionInWhereClause() async {
            let query = TestUser.all
                .where { user in
                    user.tags.arrayLength() > 5
                }

            await assertSQL(
                of: query
            ) {
                """
                SELECT "test_users"."id", "test_users"."name", "test_users"."settings", "test_users"."metadata", "test_users"."preferences", "test_users"."tags"
                FROM "test_users"
                WHERE (jsonb_array_length("test_users"."tags")) > (5)
                """
            }
        }

    }
}
