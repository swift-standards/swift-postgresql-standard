import Foundation
import PostgreSQL_Standard
import PostgreSQL_Standard_Test_Support
import Testing
import Tests_Inline_Snapshot

extension SnapshotTests.JSONB {
    @Suite("Operators") struct OperatorTests {

        @Test func containsOperator() async {

            let query = TestUser.all
                .where { user in
                    user.settings.contains(["theme": "dark"])
                }

            await assertSQL(
                of: query
            ) {
                """
                SELECT "test_users"."id", "test_users"."name", "test_users"."settings", "test_users"."metadata", "test_users"."preferences", "test_users"."tags"
                FROM "test_users"
                WHERE ("test_users"."settings" @> '{"theme":"dark"}'::jsonb)
                """
            }
        }

        @Test func containedByOperator() async {

            let query = TestUser.all
                .where { user in
                    user.settings.isContained(by: [
                        "theme": "dark", "language": "en", "timezone": "UTC",
                    ])
                }

            await assertSQL(
                of: query
            ) {
                """
                SELECT "test_users"."id", "test_users"."name", "test_users"."settings", "test_users"."metadata", "test_users"."preferences", "test_users"."tags"
                FROM "test_users"
                WHERE ("test_users"."settings" <@ '{"language":"en","theme":"dark","timezone":"UTC"}'::jsonb)
                """
            }
        }

        @Test func hasKeyOperator() async {

            let query = TestUser.all
                .where { user in
                    user.settings.hasKey("notifications")
                }

            await assertSQL(
                of: query
            ) {
                """
                SELECT "test_users"."id", "test_users"."name", "test_users"."settings", "test_users"."metadata", "test_users"."preferences", "test_users"."tags"
                FROM "test_users"
                WHERE ("test_users"."settings" ? 'notifications')
                """
            }
        }

        @Test func hasAnyKeysOperator() async {

            let query = TestUser.all
                .where { user in
                    user.settings.hasAny(of: ["theme", "color_scheme", "appearance"])
                }

            await assertSQL(
                of: query
            ) {
                """
                SELECT "test_users"."id", "test_users"."name", "test_users"."settings", "test_users"."metadata", "test_users"."preferences", "test_users"."tags"
                FROM "test_users"
                WHERE ("test_users"."settings" ?| ARRAY['theme', 'color_scheme', 'appearance'])
                """
            }
        }

        @Test func hasAllKeysOperator() async {

            let query = TestUser.all
                .where { user in
                    user.settings.hasAll(of: ["theme", "language"])
                }

            await assertSQL(
                of: query
            ) {
                """
                SELECT "test_users"."id", "test_users"."name", "test_users"."settings", "test_users"."metadata", "test_users"."preferences", "test_users"."tags"
                FROM "test_users"
                WHERE ("test_users"."settings" ?& ARRAY['theme', 'language'])
                """
            }
        }

        @Test func jsonFieldOperator() async {

            let query = TestUser.select { user in
                (user.id, user.settings.field("theme"))
            }

            await assertSQL(
                of: query
            ) {
                """
                SELECT "test_users"."id", ("test_users"."settings" -> 'theme')
                FROM "test_users"
                """
            }
        }

        @Test func jsonFieldTextOperator() async {

            let query = TestUser.select { user in
                (user.id, user.settings.fieldAsText("theme"))
            }

            await assertSQL(
                of: query
            ) {
                """
                SELECT "test_users"."id", ("test_users"."settings" ->> 'theme')
                FROM "test_users"
                """
            }
        }

        @Test func jsonElementOperator() async {

            let query = TestUser.select { user in
                (user.id, user.tags.element(at: 0))
            }

            await assertSQL(
                of: query
            ) {
                """
                SELECT "test_users"."id", ("test_users"."tags" -> 0)
                FROM "test_users"
                """
            }
        }

        @Test func jsonElementTextOperator() async {

            let query = TestUser.select { user in
                (user.id, user.tags.elementAsText(at: 1))
            }

            await assertSQL(
                of: query
            ) {
                """
                SELECT "test_users"."id", ("test_users"."tags" ->> 1)
                FROM "test_users"
                """
            }
        }

        @Test func jsonPathOperator() async {

            let query = TestUser.select { user in
                (user.id, user.metadata.value(at: ["address", "city"]))
            }

            await assertSQL(
                of: query
            ) {
                """
                SELECT "test_users"."id", ("test_users"."metadata" #> ARRAY['address', 'city']::text[])
                FROM "test_users"
                """
            }
        }

        @Test func jsonPathTextOperator() async {

            let query = TestUser.select { user in
                (user.id, user.metadata.valueAsText(at: ["contact", "email"]))
            }

            await assertSQL(
                of: query
            ) {
                """
                SELECT "test_users"."id", ("test_users"."metadata" #>> ARRAY['contact', 'email']::text[])
                FROM "test_users"
                """
            }
        }

        @Test func complexJSONBQuery() async {

            let query = TestUser.all
                .where { user in
                    user.settings.hasKey("theme") && user.settings.contains(["notifications": true])
                        && user.metadata.fieldAsText("status") == "active"
                }

            await assertSQL(
                of: query
            ) {
                """
                SELECT "test_users"."id", "test_users"."name", "test_users"."settings", "test_users"."metadata", "test_users"."preferences", "test_users"."tags"
                FROM "test_users"
                WHERE ((("test_users"."settings" ? 'theme')) AND ("test_users"."settings" @> '{"notifications":true}'::jsonb)) AND (("test_users"."metadata" ->> 'status')) = ('active')
                """
            }
        }

        @Test func nestedJSONExtraction() async {

            let query = TestUser.select { user in
                user.settings
                    .field("preferences")
                    .field("ui")
                    .fieldAsText("theme")
            }

            await assertSQL(
                of: query
            ) {
                """
                SELECT ((("test_users"."settings" -> 'preferences') -> 'ui') ->> 'theme')
                FROM "test_users"
                """
            }
        }

    }
}
