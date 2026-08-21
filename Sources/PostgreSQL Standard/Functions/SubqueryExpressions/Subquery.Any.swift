import Foundation
import Structured_Queries_Primitives

extension Subquery {

    public struct `Any`<Value: QueryBindable>: QueryExpression {
        public typealias QueryValue = Value

        public let queryFragment: QueryFragment

        public init<Q: QueryExpression>(_ subquery: Q) where Q.QueryValue == [Value] {
            self.queryFragment = "ANY (\(subquery.queryFragment))"
        }

        public init(_ subquery: QueryFragment) {
            self.queryFragment = "ANY (\(subquery))"
        }
    }
}
