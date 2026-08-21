import PostgreSQL_Standard
import Testing

extension SnapshotTests.JSONB {

    @Suite("Path Encoding") struct PathEncodingTests {

        static let reservedPath = ["a,b", "o'brien", "}"]

        static let escapePath = [#"a"b"#, #"c\d"#]

        static let reservedJoined = "a,b,o'brien,}"

        @Test func `path extraction binds elements rather than spelling them`() {
            let fragment = TestUser.columns.metadata.value(at: Self.reservedPath).queryFragment

            #expect(
                fragment.debugDescription
                    == #"("test_users"."metadata" #> ARRAY['a,b', 'o''brien', '}']::text[])"#
            )
            #expect(!fragment.debugDescription.contains(Self.reservedJoined))
        }

        @Test func `text path extraction binds elements rather than spelling them`() {
            let fragment = TestUser.columns.metadata.valueAsText(at: Self.reservedPath)
                .queryFragment

            #expect(
                fragment.debugDescription
                    == #"("test_users"."metadata" #>> ARRAY['a,b', 'o''brien', '}']::text[])"#
            )
            #expect(!fragment.debugDescription.contains(Self.reservedJoined))
        }

        @Test func `path deletion binds elements rather than spelling them`() {
            let fragment = TestUser.columns.settings.removing(path: Self.reservedPath)
                .queryFragment

            #expect(
                fragment.debugDescription
                    == #"("test_users"."settings" #- ARRAY['a,b', 'o''brien', '}']::text[])"#
            )
            #expect(!fragment.debugDescription.contains(Self.reservedJoined))
        }

        @Test func `set binds path elements rather than spelling them`() {
            let fragment = TestUser.columns.settings.setting(Self.reservedPath, to: "dark")
                .queryFragment

            #expect(fragment.debugDescription.hasPrefix("jsonb_set("))
            #expect(
                fragment.debugDescription.contains(#"ARRAY['a,b', 'o''brien', '}']::text[]"#)
            )
            #expect(!fragment.debugDescription.contains(Self.reservedJoined))
        }

        @Test func `insert binds path elements rather than spelling them`() {
            let fragment = TestUser.columns.settings.inserting("dark", at: Self.reservedPath)
                .queryFragment

            #expect(fragment.debugDescription.hasPrefix("jsonb_insert("))
            #expect(
                fragment.debugDescription.contains(#"ARRAY['a,b', 'o''brien', '}']::text[]"#)
            )
            #expect(!fragment.debugDescription.contains(Self.reservedJoined))
        }

        @Test func `an empty bound path stays a typed empty array`() {
            let fragment = TestUser.columns.metadata.value(at: []).queryFragment

            #expect(
                fragment.debugDescription == #"("test_users"."metadata" #> ARRAY[]::text[])"#
            )
        }

        @Test func `an index path literal quotes elements at the array layer`() {
            let fragment = TestUserForIndexing.createGINIndexPath(
                name: "idx_reserved",
                on: \.metadata,
                path: Self.reservedPath
            )

            #expect(
                fragment.debugDescription
                    == #"CREATE INDEX "idx_reserved" ON "test_users" USING GIN (("metadata" #> '{"a,b","o''brien","}"}'::text[]))"#
            )
            #expect(!fragment.debugDescription.contains(Self.reservedJoined))
        }

        @Test func `an index path literal escapes array-literal escape characters`() {
            let fragment = TestUserForIndexing.createGINIndexPath(
                name: "idx_escapes",
                on: \.metadata,
                path: Self.escapePath
            )

            #expect(
                fragment.debugDescription
                    == #"CREATE INDEX "idx_escapes" ON "test_users" USING GIN (("metadata" #> '{"a\"b","c\\d"}'::text[]))"#
            )
        }

        @Test func `an empty index path stays a typed empty array`() {
            let fragment = TestUserForIndexing.createGINIndexPath(
                name: "idx_empty",
                on: \.metadata,
                path: []
            )

            #expect(
                fragment.debugDescription
                    == #"CREATE INDEX "idx_empty" ON "test_users" USING GIN (("metadata" #> '{}'::text[]))"#
            )
        }
    }
}
