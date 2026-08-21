import Foundation
import PostgreSQL_Standard
import PostgreSQL_Standard_Macros
import PostgreSQL_Standard_Test_Support
import Testing
import Tests_Inline_Snapshot

extension SnapshotTests.StringFunctions {
    @Suite("String Functions") struct StringFunctionsTests {

        @Test func concat() async {
            await assertSQL(
                of: Person.select {
                    ($0.firstName + " " + $0.lastName)
                }
            ) {
                """
                SELECT (("persons"."firstName") || (' ')) || ("persons"."lastName")
                FROM "persons"
                """
            }
        }

        @Test func uppercased() async {
            await assertSQL(
                of: Person.select { $0.name.uppercased() }
            ) {
                """
                SELECT upper("persons"."name")
                FROM "persons"
                """
            }
        }

        @Test func lowercased() async {
            await assertSQL(
                of: Person.select { $0.email.lowercased() }
            ) {
                """
                SELECT lower("persons"."email")
                FROM "persons"
                """
            }
        }

        @Test func trim() async {
            await assertSQL(
                of: Person.select { $0.description.trim() }
            ) {
                """
                SELECT trim("persons"."description")
                FROM "persons"
                """
            }
        }

        @Test func substring() async {
            await assertSQL(
                of: Person.select { $0.name.substr(1, 10) }
            ) {
                """
                SELECT substr("persons"."name", 1, 10)
                FROM "persons"
                """
            }
        }
    }
}

@Table
private struct Person {
    let id: Int
    let name: String
    let email: String
    let firstName: String
    let lastName: String
    let description: String
}

extension SnapshotTests {
    enum StringFunctions {}
}
