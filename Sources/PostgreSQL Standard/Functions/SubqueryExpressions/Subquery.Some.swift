import Foundation
import Structured_Queries_Primitives

extension Subquery {
    /// Wrapper for SOME quantified comparison (synonym for ANY)
    ///
    /// PostgreSQL's SOME operator is a synonym for ANY.
    ///
    /// ```swift
    /// Product.where { $0.price < .some(competitorPrices) }
    /// // SELECT … FROM "products" WHERE "products"."price" < SOME (SELECT price FROM competitors)
    /// ```
    public struct `Some`<Value: QueryBindable>: QueryExpression {
        public typealias QueryValue = Value

        public let queryFragment: QueryFragment

        public init<Q: QueryExpression>(_ subquery: Q) where Q.QueryValue == [Value] {
            self.queryFragment = "SOME (\(subquery.queryFragment))"
        }

        public init(_ subquery: QueryFragment) {
            self.queryFragment = "SOME (\(subquery))"
        }
    }
}
