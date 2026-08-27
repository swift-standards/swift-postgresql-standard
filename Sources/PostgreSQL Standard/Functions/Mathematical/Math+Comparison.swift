import Foundation
import Structured_Queries

extension Math {

    public static func min<T: Comparable & QueryBindable>(
        _ a: some QueryExpression<T>,
        _ b: T
    ) -> some QueryExpression<T> {
        SQLQueryExpression("least(\(a.queryFragment), \(bind: b))", as: T.self)
    }

    public static func min<T: Comparable & QueryBindable>(
        _ a: some QueryExpression<T>,
        _ b: some QueryExpression<T>
    ) -> some QueryExpression<T> {
        SQLQueryExpression("least(\(a.queryFragment), \(b.queryFragment))", as: T.self)
    }

    public static func max<T: Comparable & QueryBindable>(
        _ a: some QueryExpression<T>,
        _ b: T
    ) -> some QueryExpression<T> {
        SQLQueryExpression("greatest(\(a.queryFragment), \(bind: b))", as: T.self)
    }

    public static func max<T: Comparable & QueryBindable>(
        _ a: some QueryExpression<T>,
        _ b: some QueryExpression<T>
    ) -> some QueryExpression<T> {
        SQLQueryExpression("greatest(\(a.queryFragment), \(b.queryFragment))", as: T.self)
    }
}

extension QueryExpression where QueryValue: Comparable & QueryBindable {

    @_disfavoredOverload
    public func min(_ other: QueryValue) -> some QueryExpression<QueryValue> {
        Math.min(self, other)
    }

    @_disfavoredOverload
    public func min(_ other: some QueryExpression<QueryValue>) -> some QueryExpression<QueryValue> {
        Math.min(self, other)
    }

    @_disfavoredOverload
    public func max(_ other: QueryValue) -> some QueryExpression<QueryValue> {
        Math.max(self, other)
    }

    @_disfavoredOverload
    public func max(_ other: some QueryExpression<QueryValue>) -> some QueryExpression<QueryValue> {
        Math.max(self, other)
    }
}
