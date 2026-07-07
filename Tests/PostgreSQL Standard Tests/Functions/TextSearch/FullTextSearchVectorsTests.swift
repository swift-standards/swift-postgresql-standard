import Foundation
import PostgreSQL_Standard
import PostgreSQL_Standard_Test_Support
import Testing
import Tests_Inline_Snapshot

extension SnapshotTests.FullTextSearch {
    @Suite("Vectors & Edge Cases") struct VectorsTests {

        // MARK: - Phrase Match Tests

        @Test
        func `Phrase match basic`() async {
            await assertSQL(of: Article.where { $0.phraseMatch("quick brown fox") }) {
                """
                SELECT "articles"."id", "articles"."title", "articles"."body", "articles"."searchVector"
                FROM "articles"
                WHERE "articles"."searchVector" @@ phraseto_tsquery('english'::regconfig, 'quick brown fox')
                """
            }
        }

        @Test
        func `Phrase match with custom language`() async {
            await assertSQL(
                of: Article.where { $0.phraseMatch("le chat noir", language: "french") }
            ) {
                """
                SELECT "articles"."id", "articles"."title", "articles"."body", "articles"."searchVector"
                FROM "articles"
                WHERE "articles"."searchVector" @@ phraseto_tsquery('french'::regconfig, 'le chat noir')
                """
            }
        }

        @Test
        func `Phrase match with ranking`() async {
            await assertSQL(
                of:
                    Article
                    .where { $0.phraseMatch("swift programming") }
                    .select { ($0.id, $0.title, $0.rank(by: "swift & programming")) }
            ) {
                """
                SELECT "articles"."id", "articles"."title", ts_rank("articles"."searchVector", to_tsquery('english'::regconfig, 'swift & programming'))
                FROM "articles"
                WHERE "articles"."searchVector" @@ phraseto_tsquery('english'::regconfig, 'swift programming')
                """
            }
        }

        @Test
        func `Phrase match combined with filters`() async {
            await assertSQL(
                of:
                    Article
                    .where { $0.phraseMatch("server side swift") && $0.id < 1000 }
                    .select { ($0.id, $0.title) }
            ) {
                """
                SELECT "articles"."id", "articles"."title"
                FROM "articles"
                WHERE ("articles"."searchVector" @@ phraseto_tsquery('english'::regconfig, 'server side swift')) AND ("articles"."id") < (1000)
                """
            }
        }

        // MARK: - Vector Manipulation Tests

        @Test
        func `Setweight on tsvector column`() async {
            await assertSQL(of: Article.select { $0.title.searchVector().weighted(.A) }) {
                """
                SELECT setweight(to_tsvector('english'::regconfig, "articles"."title"), 'A')
                FROM "articles"
                """
            }
        }

        @Test
        func `Setweight with different weights`() async {
            await assertSQL(
                of: Article.select {
                    (
                        $0.title.searchVector().weighted(.A),
                        $0.body.searchVector().weighted(.B),
                        $0.title.searchVector().weighted(.C),
                        $0.body.searchVector().weighted(.D)
                    )
                }
            ) {
                """
                SELECT setweight(to_tsvector('english'::regconfig, "articles"."title"), 'A'), setweight(to_tsvector('english'::regconfig, "articles"."body"), 'B'), setweight(to_tsvector('english'::regconfig, "articles"."title"), 'C'), setweight(to_tsvector('english'::regconfig, "articles"."body"), 'D')
                FROM "articles"
                """
            }
        }

        @Test
        func `Concatenate weighted vectors`() async {
            await assertSQL(
                of: Article.select {
                    $0.title.searchVector().weighted(.A)
                        .concat($0.body.searchVector().weighted(.B))
                }
            ) {
                """
                SELECT (setweight(to_tsvector('english'::regconfig, "articles"."title"), 'A') || setweight(to_tsvector('english'::regconfig, "articles"."body"), 'B'))
                FROM "articles"
                """
            }
        }

        @Test
        func `Length of tsvector`() async {
            await assertSQL(of: Article.select { $0.title.searchVector().length() }) {
                """
                SELECT length(to_tsvector('english'::regconfig, "articles"."title"))
                FROM "articles"
                """
            }
        }

        @Test
        func `Strip weights from tsvector`() async {
            await assertSQL(
                of: Article.select { $0.title.searchVector().weighted(.A).stripped() }
            ) {
                """
                SELECT strip(setweight(to_tsvector('english'::regconfig, "articles"."title"), 'A'))
                FROM "articles"
                """
            }
        }

        @Test
        func `Complex vector manipulation chain`() async {
            await assertSQL(
                of: Article.select {
                    (
                        $0.title.searchVector().weighted(.A)
                            .concat($0.body.searchVector().weighted(.B)),
                        $0.title.searchVector().length()
                    )
                }
            ) {
                """
                SELECT (setweight(to_tsvector('english'::regconfig, "articles"."title"), 'A') || setweight(to_tsvector('english'::regconfig, "articles"."body"), 'B')), length(to_tsvector('english'::regconfig, "articles"."title"))
                FROM "articles"
                """
            }
        }

        @Test
        func `Filter by vector length`() async {
            await assertSQL(of: Article.where { $0.title.searchVector().length() > 5 }) {
                """
                SELECT "articles"."id", "articles"."title", "articles"."body", "articles"."searchVector"
                FROM "articles"
                WHERE (length(to_tsvector('english'::regconfig, "articles"."title"))) > (5)
                """
            }
        }

        @Test
        func `Multi-language weighted vectors`() async {
            await assertSQL(
                of: Article.select {
                    $0.title.searchVector("french").weighted(.A)
                        .concat($0.body.searchVector("french").weighted(.B))
                }
            ) {
                """
                SELECT (setweight(to_tsvector('french'::regconfig, "articles"."title"), 'A') || setweight(to_tsvector('french'::regconfig, "articles"."body"), 'B'))
                FROM "articles"
                """
            }
        }

        // MARK: - Edge Case Tests

        @Test
        func `Empty search query`() async {
            await assertSQL(of: Article.where { $0.match("") }) {
                """
                SELECT "articles"."id", "articles"."title", "articles"."body", "articles"."searchVector"
                FROM "articles"
                WHERE "articles"."searchVector" @@ to_tsquery('english'::regconfig, '')
                """
            }
        }

        @Test
        func `Special characters in search`() async {
            await assertSQL(of: Article.where { $0.match("swift & (postgresql | mysql)") }) {
                """
                SELECT "articles"."id", "articles"."title", "articles"."body", "articles"."searchVector"
                FROM "articles"
                WHERE "articles"."searchVector" @@ to_tsquery('english'::regconfig, 'swift & (postgresql | mysql)')
                """
            }
        }

        @Test
        func `Phrase match with quotes`() async {
            await assertSQL(of: Article.where { $0.phraseMatch(#"swift "server" development"#) }) {
                """
                SELECT "articles"."id", "articles"."title", "articles"."body", "articles"."searchVector"
                FROM "articles"
                WHERE "articles"."searchVector" @@ phraseto_tsquery('english'::regconfig, 'swift "server" development')
                """
            }
        }

        @Test
        func `Web match with complex query`() async {
            await assertSQL(
                of: Article.where { $0.webMatch(#""exact phrase" OR keyword -excluded"#) }
            ) {
                """
                SELECT "articles"."id", "articles"."title", "articles"."body", "articles"."searchVector"
                FROM "articles"
                WHERE "articles"."searchVector" @@ websearch_to_tsquery('english'::regconfig, '"exact phrase" OR keyword -excluded')
                """
            }
        }

        @Test
        func `Multiple setweight operations`() async {
            await assertSQL(
                of: Article.select {
                    $0.title.searchVector().weighted(.A).stripped().weighted(.B)
                }
            ) {
                """
                SELECT setweight(strip(setweight(to_tsvector('english'::regconfig, "articles"."title"), 'A')), 'B')
                FROM "articles"
                """
            }
        }
    }
}
