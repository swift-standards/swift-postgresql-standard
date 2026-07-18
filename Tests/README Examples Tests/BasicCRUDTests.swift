import Foundation
import PostgreSQL_Standard
import PostgreSQL_Standard_Macros
import PostgreSQL_Standard_Test_Support
import Testing
import Tests_Apple_Testing_Bridge
import Tests_Inline_Snapshot

/// Tests for Basic CRUD examples shown in README.md
@Suite(
    "README Examples - Basic CRUD",
    .snapshots(record: .never)
)
struct BasicCRUDTests {

    // MARK: - Test Models

    @Table
    struct User {
        let id: Int
        var name: String
        var email: String
        var isActive: Bool = true
    }

    @Table
    struct Post {
        let id: Int
        var userId: Int
        var title: String
        var content: String
        var publishedAt: Date?
    }

    // MARK: - SELECT Examples

    @Test
    func `README Example: Basic SELECT with WHERE, ORDER BY, LIMIT`() async {
        await assertSQL(
            of:
                User
                .where { $0.isActive }
                .order(by: \.name)
                .limit(10)
        ) {
            """
            SELECT "users"."id", "users"."name", "users"."email", "users"."isActive"
            FROM "users"
            WHERE "users"."isActive"
            ORDER BY "users"."name"
            LIMIT 10
            """
        }
    }

    @Test
    func `README Example: SELECT specific columns`() async {
        await assertSQL(
            of: User.select { ($0.id, $0.name, $0.email) }
        ) {
            """
            SELECT "users"."id", "users"."name", "users"."email"
            FROM "users"
            """
        }
    }

    @Test
    func `README Example: SELECT with complex WHERE clause`() async {
        await assertSQL(
            of: User.where { $0.isActive && $0.email.hasSuffix("@example.com") }
        ) {
            """
            SELECT "users"."id", "users"."name", "users"."email", "users"."isActive"
            FROM "users"
            WHERE ("users"."isActive") AND ("users"."email" LIKE '%@example.com')
            """
        }
    }

    @Test
    func `README Example: SELECT with JOIN`() async {
        await assertSQL(
            of:
                User
                .join(Post.all) { $0.id == $1.userId }
                .where { user, _ in user.isActive }
                .select { user, post in (user.name, post.title) }
        ) {
            """
            SELECT "users"."name", "posts"."title"
            FROM "users"
            JOIN "posts" ON ("users"."id") = ("posts"."userId")
            WHERE "users"."isActive"
            """
        }
    }

    // MARK: - INSERT Examples

    @Test
    func `README Example: INSERT with Draft (NULL primary key handling)`() async {
        await assertSQL(
            of: User.insert {
                User.Draft(name: "Alice", email: "alice@example.com")
            }
        ) {
            """
            INSERT INTO "users"
            ("id", "name", "email", "isActive")
            VALUES
            (DEFAULT, 'Alice', 'alice@example.com', true)
            """
        }
    }

    @Test
    func `README Example: INSERT multiple records`() async {
        await assertSQL(
            of: User.insert {
                User.Draft(name: "Alice", email: "alice@example.com")
                User.Draft(name: "Bob", email: "bob@example.com", isActive: false)
            }
        ) {
            """
            INSERT INTO "users"
            ("id", "name", "email", "isActive")
            VALUES
            (DEFAULT, 'Alice', 'alice@example.com', true), (DEFAULT, 'Bob', 'bob@example.com', false)
            """
        }
    }

    @Test
    func `README Example: INSERT with RETURNING`() async {
        await assertSQL(
            of: User.insert {
                User.Draft(name: "Alice", email: "alice@example.com")
            }.returning(\.id)
        ) {
            """
            INSERT INTO "users"
            ("id", "name", "email", "isActive")
            VALUES
            (DEFAULT, 'Alice', 'alice@example.com', true)
            RETURNING "users"."id"
            """
        }
    }

    @Test
    func `README Example: INSERT mixed records (some with ID, some without)`() async {
        await assertSQL(
            of: User.insert {
                User(id: 1, name: "Alice", email: "alice@example.com")
                User.Draft(name: "Bob", email: "bob@example.com")
            }
        ) {
            """
            INSERT INTO "users"
            ("id", "name", "email", "isActive")
            VALUES
            (1, 'Alice', 'alice@example.com', true), (DEFAULT, 'Bob', 'bob@example.com', true)
            """
        }
    }

    // MARK: - UPDATE Examples

    @Test
    func `README Example: UPDATE with WHERE`() async {
        await assertSQL(
            of:
                User
                .where { $0.id == 1 }
                .update { $0.name = "Alice Updated" }
        ) {
            """
            UPDATE "users"
            SET "name" = 'Alice Updated'
            WHERE ("users"."id") = (1)
            """
        }
    }

    @Test
    func `README Example: UPDATE multiple columns`() async {
        await assertSQL(
            of:
                User
                .where { $0.id == 1 }
                .update {
                    $0.name = "Alice"
                    $0.email = "newemail@example.com"
                    $0.isActive = false
                }
        ) {
            """
            UPDATE "users"
            SET "name" = 'Alice', "email" = 'newemail@example.com', "isActive" = false
            WHERE ("users"."id") = (1)
            """
        }
    }

    @Test
    func `README Example: UPDATE with RETURNING`() async {
        await assertSQL(
            of:
                User
                .where { $0.id == 1 }
                .update { $0.isActive = false }
                .returning { ($0.id, $0.name) }
        ) {
            """
            UPDATE "users"
            SET "isActive" = false
            WHERE ("users"."id") = (1)
            RETURNING "users"."id", "users"."name"
            """
        }
    }

    // MARK: - DELETE Examples

    @Test
    func `README Example: DELETE with WHERE`() async {
        await assertSQL(
            of:
                User
                .where { $0.isActive == false }
                .delete()
        ) {
            """
            DELETE FROM "users"
            WHERE ("users"."isActive") = (false)
            """
        }
    }

    @Test
    func `README Example: DELETE with RETURNING`() async {
        await assertSQL(
            of:
                User
                .where { $0.id == 1 }
                .delete()
                .returning { ($0.id, $0.email) }
        ) {
            """
            DELETE FROM "users"
            WHERE ("users"."id") = (1)
            RETURNING "users"."id", "users"."email"
            """
        }
    }
}
