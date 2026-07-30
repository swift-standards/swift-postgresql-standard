import PostgreSQL_Standard
import Testing

extension SnapshotTests.JSONB {
    /// A JSONB path element is a value, not statement text.
    ///
    /// PostgreSQL spells the path argument of `#>`, `#>>`, `#-`, `jsonb_set`, and
    /// `jsonb_insert` as `text[]`. These tests pin how each path-taking builder reaches that
    /// argument over elements carrying the characters the surrounding grammars would
    /// otherwise read as structure — a comma and a brace (array-literal structure), a single
    /// quote (SQL text-literal structure), a double quote and a backslash (array-literal
    /// escapes).
    ///
    /// Every builder must address exactly the key the element spells, and no element may
    /// reach the statement as bare text.
    @Suite("Path Encoding") struct PathEncodingTests {

        /// Elements exercising array-literal and SQL text-literal structure characters.
        static let reservedPath = ["a,b", "o'brien", "}"]

        /// Elements exercising the array-literal escape characters.
        static let escapePath = [#"a"b"#, #"c\d"#]

        /// The joined spelling these elements must never produce in a statement.
        static let reservedJoined = "a,b,o'brien,}"

        // MARK: - Bound path arguments

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

        /// `jsonb_set` and `jsonb_insert` also encode a value, whose spelling is the JSON
        /// encoder's business rather than this suite's, so these assert the path argument.
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

        // MARK: - Literal path arguments

        // A CREATE INDEX expression must be a constant, so the path is written as a literal
        // rather than bound. It passes through two grammars — the array literal, then the SQL
        // text literal — and has to survive both.

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
