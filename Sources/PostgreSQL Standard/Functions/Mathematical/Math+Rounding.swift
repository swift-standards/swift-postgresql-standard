import Foundation
import Structured_Queries

extension Math {

    public static func ceil<T: Numeric & QueryBindable>(
        _ value: some QueryExpression<T>
    ) -> some QueryExpression<T> {
        SQLQueryExpression("ceil(\(value.queryFragment))", as: T.self)
    }

    public static func ceiling<T: Numeric & QueryBindable>(
        _ value: some QueryExpression<T>
    ) -> some QueryExpression<T> {
        SQLQueryExpression("ceiling(\(value.queryFragment))", as: T.self)
    }

    public static func floor<T: Numeric & QueryBindable>(
        _ value: some QueryExpression<T>
    ) -> some QueryExpression<T> {
        SQLQueryExpression("floor(\(value.queryFragment))", as: T.self)
    }

    public static func round<T: Numeric & QueryBindable>(
        _ value: some QueryExpression<T>
    ) -> some QueryExpression<T> {
        SQLQueryExpression("round(\(value.queryFragment))", as: T.self)
    }

    public static func round<T: Numeric & QueryBindable>(
        _ value: some QueryExpression<T>,
        decimalPlaces: Int
    ) -> some QueryExpression<T> {
        SQLQueryExpression("round(\(value.queryFragment), \(decimalPlaces))", as: T.self)
    }

    public static func trunc<T: Numeric & QueryBindable>(
        _ value: some QueryExpression<T>
    ) -> some QueryExpression<T> {
        SQLQueryExpression("trunc(\(value.queryFragment))", as: T.self)
    }

    public static func trunc<T: Numeric & QueryBindable>(
        _ value: some QueryExpression<T>,
        decimalPlaces: Int
    ) -> some QueryExpression<T> {
        SQLQueryExpression("trunc(\(value.queryFragment), \(decimalPlaces))", as: T.self)
    }
}

extension QueryExpression where QueryValue: Numeric & QueryBindable {

    public func ceil() -> some QueryExpression<QueryValue> {
        Math.ceil(self)
    }

    public func ceiling() -> some QueryExpression<QueryValue> {
        Math.ceiling(self)
    }

    public func floor() -> some QueryExpression<QueryValue> {
        Math.floor(self)
    }

    public func round() -> some QueryExpression<QueryValue> {
        Math.round(self)
    }

    public func round(decimalPlaces: Int) -> some QueryExpression<QueryValue> {
        Math.round(self, decimalPlaces: decimalPlaces)
    }

    public func trunc() -> some QueryExpression<QueryValue> {
        Math.trunc(self)
    }

    public func trunc(decimalPlaces: Int) -> some QueryExpression<QueryValue> {
        Math.trunc(self, decimalPlaces: decimalPlaces)
    }
}
