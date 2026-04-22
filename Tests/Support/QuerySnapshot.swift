import Test_Snapshot_Primitives
import Structured_Queries_Primitives

extension Test.Snapshot.Strategy where Value: Statement, Format == String {
    /// A snapshot strategy for comparing a query based on its SQL output.
    ///
    /// ```swift
    /// snapshot(as: .sql) {
    ///     Reminder.select(\.title)
    /// } matches: {
    ///     """
    ///     SELECT "reminders"."title" FROM "reminders"
    ///     """
    /// }
    /// ```
    public static var sql: Self {
        Test.Snapshot.Strategy<String, String>.lines.pullback(\.query.debugDescription)
    }
}

extension Test.Snapshot.Strategy where Value: QueryExpression, Format == String {
    /// A snapshot strategy for comparing a query expression based on its SQL output.
    public static var sql: Self {
        Test.Snapshot.Strategy<String, String>.lines.pullback(\.queryFragment.debugDescription)
    }
}
