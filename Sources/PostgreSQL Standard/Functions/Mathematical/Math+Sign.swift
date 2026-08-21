import Foundation
import Structured_Queries_Primitives

extension Math {

    public static func abs<T: Numeric & QueryBindable>(
        _ value: some QueryExpression<T>
    ) -> some QueryExpression<T> {
        SQLQueryExpression("abs(\(value.queryFragment))", as: T.self)
    }

    public static func sign<T: Numeric & QueryBindable>(
        _ value: some QueryExpression<T>
    ) -> some QueryExpression<T> {
        SQLQueryExpression("sign(\(value.queryFragment))", as: T.self)
    }
}

extension QueryExpression where QueryValue: Numeric & QueryBindable {

    public func abs() -> some QueryExpression<QueryValue> {
        Math.abs(self)
    }

    public func sign() -> some QueryExpression<QueryValue> {
        Math.sign(self)
    }
}
