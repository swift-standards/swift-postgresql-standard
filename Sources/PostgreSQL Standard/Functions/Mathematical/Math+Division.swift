import Foundation
import Structured_Queries

extension Math {

    public static func mod<T: Numeric & QueryBindable>(
        _ dividend: some QueryExpression<T>,
        _ divisor: T
    ) -> some QueryExpression<T> {
        SQLQueryExpression("mod(\(dividend.queryFragment), \(bind: divisor))", as: T.self)
    }

    public static func mod<T: Numeric & QueryBindable>(
        _ dividend: some QueryExpression<T>,
        _ divisor: some QueryExpression<T>
    ) -> some QueryExpression<T> {
        SQLQueryExpression(
            "mod(\(dividend.queryFragment), \(divisor.queryFragment))",
            as: T.self
        )
    }

    public static func div<T: Numeric & QueryBindable>(
        _ dividend: some QueryExpression<T>,
        _ divisor: T
    ) -> some QueryExpression<T> {
        SQLQueryExpression("div(\(dividend.queryFragment), \(bind: divisor))", as: T.self)
    }
}

extension QueryExpression where QueryValue: Numeric & QueryBindable {

    public func mod(_ divisor: QueryValue) -> some QueryExpression<QueryValue> {
        Math.mod(self, divisor)
    }

    public func mod(_ divisor: some QueryExpression<QueryValue>) -> some QueryExpression<QueryValue>
    {
        Math.mod(self, divisor)
    }

    public func div(_ divisor: QueryValue) -> some QueryExpression<QueryValue> {
        Math.div(self, divisor)
    }
}
