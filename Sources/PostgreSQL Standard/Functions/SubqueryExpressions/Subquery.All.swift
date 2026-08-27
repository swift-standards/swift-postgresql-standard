import Foundation
import Structured_Queries

extension Subquery {

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
