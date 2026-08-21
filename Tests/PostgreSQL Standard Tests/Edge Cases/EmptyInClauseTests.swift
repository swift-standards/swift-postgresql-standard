import Foundation
import PostgreSQL_Standard
import PostgreSQL_Standard_Macros
import PostgreSQL_Standard_Test_Support
import Testing
import Tests_Inline_Snapshot

extension SnapshotTests {
    @Suite struct EmptyInClauseTests {

        @Test func emptyArrayInClause() async {

            let emptyIds: [Int] = []

            await assertSQL(of: Reminder.where { $0.id.in(emptyIds) }) {
                """
                SELECT "reminders"."id", "reminders"."assignedUserID", "reminders"."dueDate", "reminders"."isCompleted", "reminders"."isFlagged", "reminders"."notes", "reminders"."priority", "reminders"."remindersListID", "reminders"."title", "reminders"."updatedAt"
                FROM "reminders"
                WHERE ("reminders"."id") IN (NULL)
                """
            }
        }

        @Test func emptyArrayInClauseWithOtherConditions() async {

            let emptyAccountIds: [UUID] = []

            await assertSQL(
                of: GitHubAccount.where { account in
                    account.id.in(emptyAccountIds).and(account.isValid.eq(true))
                }
            ) {
                """
                SELECT "github_accounts"."id", "github_accounts"."identityId", "github_accounts"."encryptedToken", "github_accounts"."tokenName", "github_accounts"."scopes", "github_accounts"."createdAt", "github_accounts"."lastValidatedAt", "github_accounts"."isValid"
                FROM "github_accounts"
                WHERE (("github_accounts"."id") IN (NULL)) AND ("github_accounts"."isValid") = (true)
                """
            }
        }

        @Test func nonEmptyArrayInClause() async {

            let ids = [1, 2, 3]

            await assertSQL(of: Reminder.where { $0.id.in(ids) }) {
                """
                SELECT "reminders"."id", "reminders"."assignedUserID", "reminders"."dueDate", "reminders"."isCompleted", "reminders"."isFlagged", "reminders"."notes", "reminders"."priority", "reminders"."remindersListID", "reminders"."title", "reminders"."updatedAt"
                FROM "reminders"
                WHERE ("reminders"."id") IN (1, 2, 3)
                """
            }
        }

        @Test func emptyStringArrayInClause() async {

            let emptyNames: [String] = []

            await assertSQL(of: Reminder.where { $0.title.in(emptyNames) }) {
                """
                SELECT "reminders"."id", "reminders"."assignedUserID", "reminders"."dueDate", "reminders"."isCompleted", "reminders"."isFlagged", "reminders"."notes", "reminders"."priority", "reminders"."remindersListID", "reminders"."title", "reminders"."updatedAt"
                FROM "reminders"
                WHERE ("reminders"."title") IN (NULL)
                """
            }
        }

        @Test func mixedConditionsWithEmptyIn() async {

            let emptyIds: [Int] = []

            await assertSQL(
                of:
                    Reminder
                    .where { reminder in
                        reminder.id.in(emptyIds)
                            .or(reminder.remindersListID.eq(1))
                    }
                    .order { $0.updatedAt.desc() }
            ) {
                """
                SELECT "reminders"."id", "reminders"."assignedUserID", "reminders"."dueDate", "reminders"."isCompleted", "reminders"."isFlagged", "reminders"."notes", "reminders"."priority", "reminders"."remindersListID", "reminders"."title", "reminders"."updatedAt"
                FROM "reminders"
                WHERE (("reminders"."id") IN (NULL)) OR ("reminders"."remindersListID") = (1)
                ORDER BY "reminders"."updatedAt" DESC
                """
            }
        }
    }
}

@Table("github_accounts")
struct GitHubAccount: Codable, Equatable, Identifiable {
    let id: UUID
    let identityId: UUID
    let encryptedToken: String
    let tokenName: String?
    @Column(as: [String].JSONB.self)
    let scopes: [String]
    let createdAt: Date
    let lastValidatedAt: Date?
    let isValid: Bool
}
