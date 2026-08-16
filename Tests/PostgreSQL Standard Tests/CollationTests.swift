import PostgreSQL_Standard
import Testing
import Tests_Inline_Snapshot

extension Collation {
    @Suite struct Test {
        @Suite struct Unit {}
    }
}

extension Collation.Test.Unit {
    @Test func `C emits the quoted built-in name`() {
        assertInlineSnapshot(of: Collation.C, as: .sql) {
            """
            "C"
            """
        }
    }

    @Test func `POSIX emits the quoted built-in name`() {
        assertInlineSnapshot(of: Collation.POSIX, as: .sql) {
            """
            "POSIX"
            """
        }
    }
}
