import Foundation
import PostgreSQL_Standard
import PostgreSQL_Standard_Test_Support
import Testing
import Tests_Inline_Snapshot

extension SnapshotTests.FullTextSearch {
    @Suite("Matching") struct MatchingTests {

        // MARK: - Match Operations

        @Test
        func `Basic match with tsquery`() async {
            await assertSQL(
                of: Article.where { $0.match("swift & postgresql") }
            ) {
                """
                SELECT "articles"."id", "articles"."title", "articles"."body", "articles"."searchVector"
                FROM "articles"
                WHERE "articles"."searchVector" @@ to_tsquery('english'::regconfig, 'swift & postgresql')
                """
            }
        }

        @Test
        func `Match with custom language`() async {
            await assertSQL(
                of: Article.where { $0.match("rapide & base", language: "french") }
            ) {
                """
                SELECT "articles"."id", "articles"."title", "articles"."body", "articles"."searchVector"
                FROM "articles"
                WHERE "articles"."searchVector" @@ to_tsquery('french'::regconfig, 'rapide & base')
                """
            }
        }

        @Test
        func `Match with OR operator`() async {
            await assertSQL(
                of: Article.where { $0.match("swift | rust | go") }
            ) {
                """
                SELECT "articles"."id", "articles"."title", "articles"."body", "articles"."searchVector"
                FROM "articles"
                WHERE "articles"."searchVector" @@ to_tsquery('english'::regconfig, 'swift | rust | go')
                """
            }
        }

        @Test
        func `Match with NOT operator`() async {
            await assertSQL(
                of: Article.where { $0.match("swift & !objective") }
            ) {
                """
                SELECT "articles"."id", "articles"."title", "articles"."body", "articles"."searchVector"
                FROM "articles"
                WHERE "articles"."searchVector" @@ to_tsquery('english'::regconfig, 'swift & !objective')
                """
            }
        }

        @Test
        func `Match with phrase operator`() async {
            await assertSQL(
                of: Article.where { $0.match("quick <-> brown <-> fox") }
            ) {
                """
                SELECT "articles"."id", "articles"."title", "articles"."body", "articles"."searchVector"
                FROM "articles"
                WHERE "articles"."searchVector" @@ to_tsquery('english'::regconfig, 'quick <-> brown <-> fox')
                """
            }
        }

        @Test
        func `Plain text match`() async {
            await assertSQL(
                of: Article.where { $0.plainMatch("swift postgresql database") }
            ) {
                """
                SELECT "articles"."id", "articles"."title", "articles"."body", "articles"."searchVector"
                FROM "articles"
                WHERE "articles"."searchVector" @@ plainto_tsquery('english'::regconfig, 'swift postgresql database')
                """
            }
        }

        @Test
        func `Web search match`() async {
            await assertSQL(
                of: Article.where { $0.webMatch(#""swift postgresql" -objective"#) }
            ) {
                """
                SELECT "articles"."id", "articles"."title", "articles"."body", "articles"."searchVector"
                FROM "articles"
                WHERE "articles"."searchVector" @@ websearch_to_tsquery('english'::regconfig, '"swift postgresql" -objective')
                """
            }
        }

        @Test
        func `Default search vector column name`() async {
            await assertSQL(
                of: FTSBlogPost.where { $0.match("content") }
            ) {
                """
                SELECT "blogPosts"."id", "blogPosts"."content", "blogPosts"."searchVector"
                FROM "blogPosts"
                WHERE "blogPosts"."searchVector" @@ to_tsquery('english'::regconfig, 'content')
                """
            }
        }

        @Test
        func `Match text column directly`() async {
            await assertSQL(
                of: Article.where { $0.title.match("swift") }
            ) {
                """
                SELECT "articles"."id", "articles"."title", "articles"."body", "articles"."searchVector"
                FROM "articles"
                WHERE to_tsvector('english'::regconfig, "articles"."title") @@ to_tsquery('english'::regconfig, 'swift')
                """
            }
        }

        @Test
        func `Match text column with language`() async {
            await assertSQL(
                of: Article.where { $0.body.match("database", language: "simple") }
            ) {
                """
                SELECT "articles"."id", "articles"."title", "articles"."body", "articles"."searchVector"
                FROM "articles"
                WHERE to_tsvector('simple'::regconfig, "articles"."body") @@ to_tsquery('simple'::regconfig, 'database')
                """
            }
        }
    }
}
