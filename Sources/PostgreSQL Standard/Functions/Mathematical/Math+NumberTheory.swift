import Foundation
import Structured_Queries_Primitives

extension Math {

    public static func gcd<T: Numeric & QueryBindable>(
        _ a: some QueryExpression<T>,
        _ b: T
    ) -> some QueryExpression<T> {
        SQLQueryExpression("gcd(\(a.queryFragment), \(bind: b))", as: T.self)
    }

    public static func gcd<T: Numeric & QueryBindable>(
        _ a: some QueryExpression<T>,
        _ b: some QueryExpression<T>
    ) -> some QueryExpression<T> {
        SQLQueryExpression("gcd(\(a.queryFragment), \(b.queryFragment))", as: T.self)
    }

    public static func lcm<T: Numeric & QueryBindable>(
        _ a: some QueryExpression<T>,
        _ b: T
    ) -> some QueryExpression<T> {
        SQLQueryExpression("lcm(\(a.queryFragment), \(bind: b))", as: T.self)
    }

    public static func lcm<T: Numeric & QueryBindable>(
        _ a: some QueryExpression<T>,
        _ b: some QueryExpression<T>
    ) -> some QueryExpression<T> {
        SQLQueryExpression("lcm(\(a.queryFragment), \(b.queryFragment))", as: T.self)
    }

    public static func factorial(_ value: some QueryExpression<Int>) -> some QueryExpression<Int> {
        SQLQueryExpression("factorial(\(value.queryFragment))", as: Int.self)
    }

    public static func minScale<T: Numeric & QueryBindable>(
        _ value: some QueryExpression<T>
    ) -> some QueryExpression<Int> {
        SQLQueryExpression("min_scale(\(value.queryFragment))", as: Int.self)
    }

    public static func trimScale<T: Numeric & QueryBindable>(
        _ value: some QueryExpression<T>
    ) -> some QueryExpression<T> {
        SQLQueryExpression("trim_scale(\(value.queryFragment))", as: T.self)
    }
}

extension QueryExpression where QueryValue: Numeric & QueryBindable {

    public func gcd(_ other: QueryValue) -> some QueryExpression<QueryValue> {
        Math.gcd(self, other)
    }

    public func gcd(_ other: some QueryExpression<QueryValue>) -> some QueryExpression<QueryValue> {
        Math.gcd(self, other)
    }

    public func lcm(_ other: QueryValue) -> some QueryExpression<QueryValue> {
        Math.lcm(self, other)
    }

    public func lcm(_ other: some QueryExpression<QueryValue>) -> some QueryExpression<QueryValue> {
        Math.lcm(self, other)
    }

    public func minScale() -> some QueryExpression<Int> {
        Math.minScale(self)
    }

    public func trimScale() -> some QueryExpression<QueryValue> {
        Math.trimScale(self)
    }
}

extension QueryExpression where QueryValue == Int {

    public func factorial() -> some QueryExpression<Int> {
        Math.factorial(self)
    }
}
