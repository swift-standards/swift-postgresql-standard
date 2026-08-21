public import Foundation
import PostgreSQL_Standard
import PostgreSQL_Standard_Macros
import PostgreSQL_Standard_Test_Support
import Testing
import Tests_Inline_Snapshot

@Suite("README Examples - JSONB Operations")
struct JSONBExamplesTests {

    @Table
    struct User {
        let id: Int
        var name: String
        var settings: Foundation.Data
    }

    @Test
    func `README Example: JSONB contains (@>) operator`() async {
        await assertSQL(
            of: User.where { $0.settings.contains(["theme": "dark"]) }
        ) {
            """
            SELECT "users"."id", "users"."name", "users"."settings"
            FROM "users"
            WHERE ("users"."settings" @> '{"theme":"dark"}'::jsonb)
            """
        }
    }

    @Test
    func `README Example: JSONB get text field (->>) operator`() async {
        await assertSQL(
            of: User.where { $0.settings.fieldAsText("theme") == "dark" }
        ) {
            """
            SELECT "users"."id", "users"."name", "users"."settings"
            FROM "users"
            WHERE (("users"."settings" ->> 'theme')) = ('dark')
            """
        }
    }

    @Test
    func `README Example: JSONB has key (?) operator`() async {
        await assertSQL(
            of: User.where { $0.settings.hasKey("notifications") }
        ) {
            """
            SELECT "users"."id", "users"."name", "users"."settings"
            FROM "users"
            WHERE ("users"."settings" ? 'notifications')
            """
        }
    }
}
