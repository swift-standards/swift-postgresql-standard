import Foundation
import PostgreSQL_Standard
import PostgreSQL_Standard_Macros
import PostgreSQL_Standard_Test_Support
import Testing
import Tests_Inline_Snapshot

extension SnapshotTests.PostgresArrayOps {
    @Suite("Array Manipulation") struct ArrayManipulationTests {

        @Test
        func `Swift stdlib .joined() vs SQL .joined() - disambiguation`() async {

            let tagNames = ["swift", "postgres", "server"]
            let swiftJoined = tagNames.joined(separator: ", ")
            #expect(swiftJoined == "swift, postgres, server")

            await assertSQL(

                of: Post.select { $0.tags.joined(separator: ", ") }
            ) {
                """
                SELECT array_to_string("posts"."tags", ', ')
                FROM "posts"
                """
            }
        }

        @Test func removing() async {
            await assertSQL(
                of: Post.select { $0.tags.removing("deprecated") }
            ) {
                """
                SELECT array_remove("posts"."tags", 'deprecated')
                FROM "posts"
                """
            }
        }

        @Test func replacing() async {
            await assertSQL(
                of: Post.select { $0.tags.replacing("old-tag", with: "new-tag") }
            ) {
                """
                SELECT array_replace("posts"."tags", 'old-tag', 'new-tag')
                FROM "posts"
                """
            }
        }

        @Test func joinedWithNullReplacement() async {
            await assertSQL(
                of: Post.select { $0.tags.joined(separator: ", ", nullReplacement: "[none]") }
            ) {
                """
                SELECT array_to_string("posts"."tags", ', ', '[none]')
                FROM "posts"
                """
            }
        }

        @Test func dimensions() async {
            await assertSQL(
                of: Post.select { $0.tags.dimensions }
            ) {
                """
                SELECT array_dims("posts"."tags")
                FROM "posts"
                """
            }
        }

        @Test func toJSON() async {
            await assertSQL(
                of: Post.select { $0.tags.toJSON() }
            ) {
                """
                SELECT array_to_json("posts"."tags")
                FROM "posts"
                """
            }
        }

        @Test func toJSONPrettyPrint() async {
            await assertSQL(
                of: Post.select { $0.tags.toJSON(prettyPrint: true) }
            ) {
                """
                SELECT array_to_json("posts"."tags", true)
                FROM "posts"
                """
            }
        }

        @Test func split() async {
            await assertSQL(
                of: Account.select { $0.commaSeparatedTags.split(separator: ",") }
            ) {
                """
                SELECT string_to_array("accounts"."commaSeparatedTags", ',')
                FROM "accounts"
                """
            }
        }

        @Test func splitWithNullString() async {
            await assertSQL(
                of: Account.select {
                    $0.commaSeparatedTags.split(separator: ",", nullString: "NULL")
                }
            ) {
                """
                SELECT string_to_array("accounts"."commaSeparatedTags", ',', 'NULL')
                FROM "accounts"
                """
            }
        }

        @Test func appending() async {
            await assertSQL(
                of: Post.select { $0.tags.appending("swift") }
            ) {
                """
                SELECT array_append("posts"."tags", 'swift')
                FROM "posts"
                """
            }
        }

        @Test func prepending() async {
            await assertSQL(
                of: Post.select { $0.tags.prepending("featured") }
            ) {
                """
                SELECT array_prepend('featured', "posts"."tags")
                FROM "posts"
                """
            }
        }

        @Test func concatenatingArray() async {
            await assertSQL(
                of: Post.select { $0.tags.concatenating(["archived", "reviewed"]) }
            ) {
                """
                SELECT array_cat("posts"."tags", ARRAY['archived', 'reviewed'])
                FROM "posts"
                """
            }
        }

        @Test
        func `Properly escapes special characters in array manipulation`() async {
            await assertSQL(
                of: Post.select { $0.tags.appending("it's \"quoted\"") }
            ) {
                """
                SELECT array_append("posts"."tags", 'it''s "quoted"')
                FROM "posts"
                """
            }
        }

        @Test
        func `Display tags as comma-separated string`() async {

            await assertSQL(
                of: Post.select { ($0.title, $0.tags.joined(separator: ", ")) }
            ) {
                """
                SELECT "posts"."title", array_to_string("posts"."tags", ', ')
                FROM "posts"
                """
            }
        }

        @Test
        func `Remove deprecated tag from all posts`() async {

            await assertSQL(
                of: Post.update { $0.tags = $0.tags.removing("deprecated") }
            ) {
                """
                UPDATE "posts"
                SET "tags" = array_remove("posts"."tags", 'deprecated')
                """
            }
        }

        @Test
        func `Rename tag across all posts`() async {

            await assertSQL(
                of: Post.update { $0.tags = $0.tags.replacing("old-name", with: "new-name") }
            ) {
                """
                UPDATE "posts"
                SET "tags" = array_replace("posts"."tags", 'old-name', 'new-name')
                """
            }
        }

        @Test
        func `Parse CSV string into array column`() async {

            await assertSQL(
                of: Account.update { $0.tags = $0.commaSeparatedTags.split(separator: ",") }
            ) {
                """
                UPDATE "accounts"
                SET "tags" = string_to_array("accounts"."commaSeparatedTags", ',')
                """
            }
        }

        @Test
        func `Export array as JSON for API response`() async {

            await assertSQL(
                of: Post.select { ($0.id, $0.tags.toJSON()) }
            ) {
                """
                SELECT "posts"."id", array_to_json("posts"."tags")
                FROM "posts"
                """
            }
        }
    }
}

@Table
private struct Post {
    let id: Int
    let title: String
    @Column(as: [String].self)
    let tags: [String]
}

@Table("accounts")
private struct Account {
    let id: Int
    let commaSeparatedTags: String
    @Column(as: [String].self)
    let tags: [String]
}
