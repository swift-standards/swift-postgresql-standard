import Foundation
import Structured_Queries_Primitives

extension Subquery {

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
