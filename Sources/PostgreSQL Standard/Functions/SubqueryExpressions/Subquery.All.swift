import Foundation
import Structured_Queries_Primitives

extension Subquery {
    /// Wrapper for ALL quantified comparison
    ///
    /// PostgreSQL's ALL operator returns true if the comparison is true for all values in the subquery.
    ///
    /// ```swift
    /// User.where { $0.score > .all(teamScores) }
    /// // SELECT … FROM "users" WHERE "users"."score" > ALL (SELECT score FROM team_members)
    /// ```
    public struct `All`<Value: QueryBindable>: QueryExpression {
        public typealias QueryValue = Value

        public let queryFragment: QueryFragment

        public init<Q: QueryExpression>(_ subquery: Q) where Q.QueryValue == [Value] {
            self.queryFragment = "ALL (\(subquery.queryFragment))"
        }

        public init(_ subquery: QueryFragment) {
            self.queryFragment = "ALL (\(subquery))"
        }
    }
}
