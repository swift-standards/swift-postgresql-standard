import Foundation
import Tests_Inline_Snapshot
import PostgreSQL_Standard
import PostgreSQL_Standard_Test_Support
import Testing

extension SnapshotTests.FullTextSearch {
    @Suite("Ranking") struct RankingTests {

        // MARK: - Basic Ranking

        @Test
        func `Basic rank`() async {
            await assertSQL(
                of:
                    Article
                    .where { $0.match("swift") }
                    .select { ($0, $0.rank(by: "swift")) }
            ) {
                """
                SELECT "articles"."id", "articles"."title", "articles"."body", "articles"."searchVector", ts_rank("articles"."searchVector", to_tsquery('english'::regconfig, 'swift'))
                FROM "articles"
                WHERE "articles"."searchVector" @@ to_tsquery('english'::regconfig, 'swift')
                """
            }
        }

        @Test
        func `Rank with normalization`() async {
            await assertSQL(
                of:
                    Article
                    .where { $0.match("swift") }
                    .select { ($0, $0.rank(by: "swift", normalization: .divideByLogLength)) }
            ) {
                """
                SELECT "articles"."id", "articles"."title", "articles"."body", "articles"."searchVector", ts_rank("articles"."searchVector", to_tsquery('english'::regconfig, 'swift'), 1)
                FROM "articles"
                WHERE "articles"."searchVector" @@ to_tsquery('english'::regconfig, 'swift')
                """
            }
        }

        @Test
        func `Rank with combined normalization flags`() async {
            await assertSQL(
                of:
                    Article
                    .where { $0.match("swift") }
                    .select {
                        (
                            $0,
                            $0.rank(
                                by: "swift", normalization: [.divideByLogLength, .divideByLength])
                        )
                    }
            ) {
                """
                SELECT "articles"."id", "articles"."title", "articles"."body", "articles"."searchVector", ts_rank("articles"."searchVector", to_tsquery('english'::regconfig, 'swift'), 3)
                FROM "articles"
                WHERE "articles"."searchVector" @@ to_tsquery('english'::regconfig, 'swift')
                """
            }
        }

        @Test
        func `Coverage-based rank`() async {
            await assertSQL(
                of:
                    Article
                    .where { $0.match("quick <-> brown") }
                    .select { ($0, $0.rank(byCoverage: "quick <-> brown")) }
            ) {
                """
                SELECT "articles"."id", "articles"."title", "articles"."body", "articles"."searchVector", ts_rank_cd("articles"."searchVector", to_tsquery('english'::regconfig, 'quick <-> brown'))
                FROM "articles"
                WHERE "articles"."searchVector" @@ to_tsquery('english'::regconfig, 'quick <-> brown')
                """
            }
        }

        // MARK: - Weighted Ranking

        @Test
        func `Rank with custom weights`() async {
            await assertSQL(
                of:
                    Article
                    .where { $0.match("swift") }
                    .select { ($0.id, $0.rank(by: "swift", weights: [0.1, 0.2, 0.4, 1.0])) }
            ) {
                """
                SELECT "articles"."id", ts_rank(ARRAY[0.1, 0.2, 0.4, 1.0], "articles"."searchVector", to_tsquery('english'::regconfig, 'swift'))
                FROM "articles"
                WHERE "articles"."searchVector" @@ to_tsquery('english'::regconfig, 'swift')
                """
            }
        }

        @Test
        func `Rank with weights and normalization`() async {
            await assertSQL(
                of:
                    Article
                    .where { $0.match("swift") }
                    .select {
                        (
                            $0.id,
                            $0.rank(
                                by: "swift", weights: [0.1, 0.2, 0.4, 1.0],
                                normalization: .divideByLogLength)
                        )
                    }
            ) {
                """
                SELECT "articles"."id", ts_rank(ARRAY[0.1, 0.2, 0.4, 1.0], "articles"."searchVector", to_tsquery('english'::regconfig, 'swift'), 1)
                FROM "articles"
                WHERE "articles"."searchVector" @@ to_tsquery('english'::regconfig, 'swift')
                """
            }
        }

        @Test
        func `Rank with weights and language`() async {
            await assertSQL(
                of:
                    Article
                    .where { $0.match("développement", language: "french") }
                    .select {
                        (
                            $0.id,
                            $0.rank(
                                by: "développement", weights: [0.2, 0.3, 0.5, 1.0],
                                language: "french")
                        )
                    }
            ) {
                """
                SELECT "articles"."id", ts_rank(ARRAY[0.2, 0.3, 0.5, 1.0], "articles"."searchVector", to_tsquery('french'::regconfig, 'développement'))
                FROM "articles"
                WHERE "articles"."searchVector" @@ to_tsquery('french'::regconfig, 'développement')
                """
            }
        }

        @Test
        func `Coverage rank with custom weights`() async {
            await assertSQL(
                of:
                    Article
                    .where { $0.match("quick <-> brown") }
                    .select {
                        (
                            $0.id,
                            $0.rank(byCoverage: "quick <-> brown", weights: [0.1, 0.2, 0.4, 1.0])
                        )
                    }
            ) {
                """
                SELECT "articles"."id", ts_rank_cd(ARRAY[0.1, 0.2, 0.4, 1.0], "articles"."searchVector", to_tsquery('english'::regconfig, 'quick <-> brown'))
                FROM "articles"
                WHERE "articles"."searchVector" @@ to_tsquery('english'::regconfig, 'quick <-> brown')
                """
            }
        }

        @Test
        func `Coverage rank with weights and normalization`() async {
            await assertSQL(
                of:
                    Article
                    .where { $0.match("swift & postgresql") }
                    .select {
                        (
                            $0.id,
                            $0.rank(
                                byCoverage: "swift & postgresql", weights: [0.1, 0.2, 0.4, 1.0],
                                normalization: .divideByLength)
                        )
                    }
            ) {
                """
                SELECT "articles"."id", ts_rank_cd(ARRAY[0.1, 0.2, 0.4, 1.0], "articles"."searchVector", to_tsquery('english'::regconfig, 'swift & postgresql'), 2)
                FROM "articles"
                WHERE "articles"."searchVector" @@ to_tsquery('english'::regconfig, 'swift & postgresql')
                """
            }
        }

        @Test
        func `Compare standard vs coverage ranking with weights`() async {
            await assertSQL(
                of:
                    Article
                    .where { $0.match("swift") }
                    .select {
                        (
                            $0.id,
                            $0.rank(by: "swift", weights: [0.1, 0.2, 0.4, 1.0]),
                            $0.rank(byCoverage: "swift", weights: [0.1, 0.2, 0.4, 1.0])
                        )
                    }
            ) {
                """
                SELECT "articles"."id", ts_rank(ARRAY[0.1, 0.2, 0.4, 1.0], "articles"."searchVector", to_tsquery('english'::regconfig, 'swift')), ts_rank_cd(ARRAY[0.1, 0.2, 0.4, 1.0], "articles"."searchVector", to_tsquery('english'::regconfig, 'swift'))
                FROM "articles"
                WHERE "articles"."searchVector" @@ to_tsquery('english'::regconfig, 'swift')
                """
            }
        }

        @Test
        func `Rank with zero weight`() async {
            await assertSQL(
                of:
                    Article
                    .where { $0.match("swift") }
                    .select { ($0.id, $0.rank(by: "swift", weights: [0.0, 0.0, 0.0, 1.0])) }
            ) {
                """
                SELECT "articles"."id", ts_rank(ARRAY[0.0, 0.0, 0.0, 1.0], "articles"."searchVector", to_tsquery('english'::regconfig, 'swift'))
                FROM "articles"
                WHERE "articles"."searchVector" @@ to_tsquery('english'::regconfig, 'swift')
                """
            }
        }
    }
}
