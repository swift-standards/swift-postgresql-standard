import Foundation
import PostgreSQL_Standard
import PostgreSQL_Standard_Macros
import PostgreSQL_Standard_Test_Support
import Testing
import Tests_Inline_Snapshot

extension SnapshotTests.PostgresArrayOps {
    @Suite("Array Operators") struct ArrayOperatorsTests {

        @Test func containsArray() async {
            await assertSQL(
                of: Post.where { $0.tags.contains(["swift", "postgres"]) }
            ) {
                """
                SELECT "posts"."id", "posts"."title", "posts"."tags"
                FROM "posts"
                WHERE ("posts"."tags" @> ARRAY['swift', 'postgres'])
                """
            }
        }

        @Test func containsArrayExpression() async {
            await assertSQL(
                of: Post.where { $0.tags.contains($0.tags) }
            ) {
                """
                SELECT "posts"."id", "posts"."title", "posts"."tags"
                FROM "posts"
                WHERE ("posts"."tags" @> "posts"."tags")
                """
            }
        }

        @Test func isContainedBy() async {
            await assertSQL(
                of: Post.where { $0.tags.isContainedBy(["swift", "postgres", "server", "web"]) }
            ) {
                """
                SELECT "posts"."id", "posts"."title", "posts"."tags"
                FROM "posts"
                WHERE ("posts"."tags" <@ ARRAY['swift', 'postgres', 'server', 'web'])
                """
            }
        }

        @Test func isContainedByExpression() async {
            await assertSQL(
                of: Post.where { $0.tags.isContainedBy($0.tags) }
            ) {
                """
                SELECT "posts"."id", "posts"."title", "posts"."tags"
                FROM "posts"
                WHERE ("posts"."tags" <@ "posts"."tags")
                """
            }
        }

        @Test func overlaps() async {
            await assertSQL(
                of: Post.where { $0.tags.overlaps(["swift", "rust"]) }
            ) {
                """
                SELECT "posts"."id", "posts"."title", "posts"."tags"
                FROM "posts"
                WHERE ("posts"."tags" && ARRAY['swift', 'rust'])
                """
            }
        }

        @Test func overlapsExpression() async {
            await assertSQL(
                of: Post.where { $0.tags.overlaps($0.tags) }
            ) {
                """
                SELECT "posts"."id", "posts"."title", "posts"."tags"
                FROM "posts"
                WHERE ("posts"."tags" && "posts"."tags")
                """
            }
        }

        @Test func concatArrays() async {
            await assertSQL(
                of: Post.select { $0.tags.arrayConcat(["new-tag"]) }
            ) {
                """
                SELECT ("posts"."tags" || ARRAY['new-tag'])
                FROM "posts"
                """
            }
        }

        @Test func concatArrayExpressions() async {
            await assertSQL(
                of: Post.select { $0.tags.arrayConcat($0.tags) }
            ) {
                """
                SELECT ("posts"."tags" || "posts"."tags")
                FROM "posts"
                """
            }
        }

        @Test func concatElement() async {
            await assertSQL(
                of: Post.select { $0.tags.arrayConcat("new-tag") }
            ) {
                """
                SELECT ("posts"."tags" || 'new-tag')
                FROM "posts"
                """
            }
        }

        @Test func arrayEquals() async {
            await assertSQL(
                of: Post.where { $0.tags.arrayEquals(["swift", "postgres"]) }
            ) {
                """
                SELECT "posts"."id", "posts"."title", "posts"."tags"
                FROM "posts"
                WHERE ("posts"."tags" = ARRAY['swift', 'postgres'])
                """
            }
        }

        @Test func arrayEqualsExpression() async {
            await assertSQL(
                of: Post.where { $0.tags.arrayEquals($0.tags) }
            ) {
                """
                SELECT "posts"."id", "posts"."title", "posts"."tags"
                FROM "posts"
                WHERE ("posts"."tags" = "posts"."tags")
                """
            }
        }

        @Test func arrayNotEquals() async {
            await assertSQL(
                of: Post.where { $0.tags.arrayNotEquals(["default"]) }
            ) {
                """
                SELECT "posts"."id", "posts"."title", "posts"."tags"
                FROM "posts"
                WHERE ("posts"."tags" <> ARRAY['default'])
                """
            }
        }

        @Test func arrayLessThan() async {
            await assertSQL(
                of: Post.where { $0.tags.arrayLessThan(["zzz"]) }
            ) {
                """
                SELECT "posts"."id", "posts"."title", "posts"."tags"
                FROM "posts"
                WHERE ("posts"."tags" < ARRAY['zzz'])
                """
            }
        }

        @Test func arrayGreaterThan() async {
            await assertSQL(
                of: Post.where { $0.tags.arrayGreaterThan(["aaa"]) }
            ) {
                """
                SELECT "posts"."id", "posts"."title", "posts"."tags"
                FROM "posts"
                WHERE ("posts"."tags" > ARRAY['aaa'])
                """
            }
        }

        @Test
        func `Array operators properly escape special characters`() async {

            await assertSQL(
                of: Post.where { $0.tags.contains(["it's", "\"quoted\"", "back\\slash"]) }
            ) {
                """
                SELECT "posts"."id", "posts"."title", "posts"."tags"
                FROM "posts"
                WHERE ("posts"."tags" @> ARRAY['it''s', '"quoted"', 'back\\slash'])
                """
            }
        }

        @Test
        func `Array operators handle unicode correctly`() async {
            await assertSQL(
                of: Post.where { $0.tags.contains(["🚀", "日本語", "émoji"]) }
            ) {
                """
                SELECT "posts"."id", "posts"."title", "posts"."tags"
                FROM "posts"
                WHERE ("posts"."tags" @> ARRAY['🚀', '日本語', 'émoji'])
                """
            }
        }

        @Test
        func `Unicode normalization: Combining characters`() async {

            let precomposed = "café"
            let decomposed = "cafe\u{0301}"

            await assertSQL(
                of: Post.where { $0.tags.contains([precomposed, decomposed]) }
            ) {
                """
                SELECT "posts"."id", "posts"."title", "posts"."tags"
                FROM "posts"
                WHERE ("posts"."tags" @> ARRAY['café', 'café'])
                """
            }
        }

        @Test
        func `Unicode: Right-to-left text (Arabic)`() async {
            await assertSQL(
                of: Post.where { $0.tags.contains(["مرحبا", "العربية"]) }
            ) {
                """
                SELECT "posts"."id", "posts"."title", "posts"."tags"
                FROM "posts"
                WHERE ("posts"."tags" @> ARRAY['مرحبا', 'العربية'])
                """
            }
        }

        @Test
        func `Unicode: Mixed scripts and emoji with skin tones`() async {
            await assertSQL(
                of: Post.where { $0.tags.contains(["Hello世界", "👨‍👩‍👧‍👦", "🏳️‍🌈"]) }
            ) {
                """
                SELECT "posts"."id", "posts"."title", "posts"."tags"
                FROM "posts"
                WHERE ("posts"."tags" @> ARRAY['Hello世界', '👨‍👩‍👧‍👦', '🏳️‍🌈'])
                """
            }
        }

        @Test
        func `Empty arrays are handled correctly`() async {
            await assertSQL(
                of: Post.where { $0.tags.contains([]) }
            ) {
                """
                SELECT "posts"."id", "posts"."title", "posts"."tags"
                FROM "posts"
                WHERE ("posts"."tags" @> ARRAY[])
                """
            }
        }

        @Test
        func `Find posts with required tags (AND logic)`() async {

            await assertSQL(
                of: Post.where { $0.tags.contains(["swift", "tutorial", "beginner"]) }
            ) {
                """
                SELECT "posts"."id", "posts"."title", "posts"."tags"
                FROM "posts"
                WHERE ("posts"."tags" @> ARRAY['swift', 'tutorial', 'beginner'])
                """
            }
        }

        @Test
        func `Find posts with any matching tag (OR logic)`() async {

            await assertSQL(
                of: Post.where { $0.tags.overlaps(["swift", "rust", "go"]) }
            ) {
                """
                SELECT "posts"."id", "posts"."title", "posts"."tags"
                FROM "posts"
                WHERE ("posts"."tags" && ARRAY['swift', 'rust', 'go'])
                """
            }
        }

        @Test
        func `Find posts tagged as subset of allowed tags`() async {

            await assertSQL(
                of: Post.where {
                    $0.tags.isContainedBy(["swift", "postgres", "vapor", "server"])
                }
            ) {
                """
                SELECT "posts"."id", "posts"."title", "posts"."tags"
                FROM "posts"
                WHERE ("posts"."tags" <@ ARRAY['swift', 'postgres', 'vapor', 'server'])
                """
            }
        }

        @Test
        func `Add tag to existing tags`() async {

            await assertSQL(
                of: Post.select { $0.tags.arrayConcat("featured") }
            ) {
                """
                SELECT ("posts"."tags" || 'featured')
                FROM "posts"
                """
            }
        }

        @Test
        func `Merge two tag arrays`() async {

            await assertSQL(
                of: Post.select { $0.tags.arrayConcat(["archived", "reviewed"]) }
            ) {
                """
                SELECT ("posts"."tags" || ARRAY['archived', 'reviewed'])
                FROM "posts"
                """
            }
        }

        @Test
        func `Filter posts not tagged with default tags`() async {

            await assertSQL(
                of: Post.where { $0.tags.arrayNotEquals(["uncategorized"]) }
            ) {
                """
                SELECT "posts"."id", "posts"."title", "posts"."tags"
                FROM "posts"
                WHERE ("posts"."tags" <> ARRAY['uncategorized'])
                """
            }
        }

        @Test
        func `Compare tags alphabetically`() async {

            await assertSQL(
                of: Post.where { $0.tags.arrayLessThan(["zzz"]) }
            ) {
                """
                SELECT "posts"."id", "posts"."title", "posts"."tags"
                FROM "posts"
                WHERE ("posts"."tags" < ARRAY['zzz'])
                """
            }
        }

        @Test func arrayLength() async {
            await assertSQL(
                of: Post.where { ($0.tags.arrayLength() ?? 0) > 3 }
            ) {
                """
                SELECT "posts"."id", "posts"."title", "posts"."tags"
                FROM "posts"
                WHERE (coalesce(array_length("posts"."tags", 1), 0)) > (3)
                """
            }
        }

        @Test func cardinality() async {
            await assertSQL(
                of: Post.where { ($0.tags.cardinality() ?? 0) > 0 }
            ) {
                """
                SELECT "posts"."id", "posts"."title", "posts"."tags"
                FROM "posts"
                WHERE (coalesce(cardinality("posts"."tags"), 0)) > (0)
                """
            }
        }

        @Test func arrayPosition() async {
            await assertSQL(
                of: Post.select { $0.tags.arrayPosition("swift") }
            ) {
                """
                SELECT array_position("posts"."tags", 'swift')
                FROM "posts"
                """
            }
        }

        @Test func arrayPositionWithStart() async {
            await assertSQL(
                of: Post.select { $0.tags.arrayPosition("swift", startingFrom: 2) }
            ) {
                """
                SELECT array_position("posts"."tags", 'swift', 2)
                FROM "posts"
                """
            }
        }

        @Test func arrayPositions() async {
            await assertSQL(
                of: Post.select { $0.tags.arrayPositions("swift") }
            ) {
                """
                SELECT array_positions("posts"."tags", 'swift')
                FROM "posts"
                """
            }
        }

        @Test func arrayLower() async {
            await assertSQL(
                of: Post.select { $0.tags.arrayLower() }
            ) {
                """
                SELECT array_lower("posts"."tags", 1)
                FROM "posts"
                """
            }
        }

        @Test func arrayUpper() async {
            await assertSQL(
                of: Post.select { $0.tags.arrayUpper() }
            ) {
                """
                SELECT array_upper("posts"."tags", 1)
                FROM "posts"
                """
            }
        }

        @Test func arrayNdims() async {
            await assertSQL(
                of: Post.select { $0.tags.arrayNdims() }
            ) {
                """
                SELECT array_ndims("posts"."tags")
                FROM "posts"
                """
            }
        }

        @Test
        func `Posts with at least 3 tags including 'swift'`() async {

            await assertSQL(
                of: Post.where {
                    ($0.tags.cardinality() ?? 0) >= 3 && $0.tags.contains(["swift"])
                }
            ) {
                """
                SELECT "posts"."id", "posts"."title", "posts"."tags"
                FROM "posts"
                WHERE ((coalesce(cardinality("posts"."tags"), 0)) >= (3)) AND ("posts"."tags" @> ARRAY['swift'])
                """
            }
        }

        @Test
        func `Posts with overlapping interests but not exactly matching`() async {

            await assertSQL(
                of: Post.where {
                    $0.tags.overlaps(["swift", "vapor"])
                        && !$0.tags.arrayEquals(["swift", "vapor"])
                }
            ) {
                """
                SELECT "posts"."id", "posts"."title", "posts"."tags"
                FROM "posts"
                WHERE (("posts"."tags" && ARRAY['swift', 'vapor'])) AND (NOT (("posts"."tags" = ARRAY['swift', 'vapor'])))
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

extension SnapshotTests {
    enum PostgresArrayOps {}
}
