import Foundation
import Structured_Queries_Primitives

extension PostgreSQL.String {

    public static func replace(
        _ value: some QueryExpression<Swift.String>,
        _ substring: Swift.String,
        _ newSubstring: Swift.String
    ) -> some QueryExpression<Swift.String> {
        SQLQueryExpression(
            "replace(\(value.queryFragment), \(bind: substring), \(bind: newSubstring))",
            as: Swift.String.self
        )
    }

    public static func replace(
        _ value: some QueryExpression<Swift.String>,
        _ other: some QueryExpression<Swift.String>,
        _ replacement: some QueryExpression<Swift.String>
    ) -> some QueryExpression<Swift.String> {
        QueryFunction("replace", value, other, replacement)
    }

    public static func translate(
        _ value: some QueryExpression<Swift.String>,
        from: Swift.String,
        to: Swift.String
    ) -> some QueryExpression<Swift.String> {
        SQLQueryExpression(
            "translate(\(value.queryFragment), \(bind: from), \(bind: to))",
            as: Swift.String.self
        )
    }

    public static func overlay(
        _ value: some QueryExpression<Swift.String>,
        placing newSubstring: Swift.String,
        from position: Int,
        for length: Int? = nil
    ) -> some QueryExpression<Swift.String> {
        if let length {
            return SQLQueryExpression(
                "overlay(\(value.queryFragment) placing \(bind: newSubstring) from \(position) for \(length))",
                as: Swift.String.self
            )
        } else {
            return SQLQueryExpression(
                "overlay(\(value.queryFragment) placing \(bind: newSubstring) from \(position))",
                as: Swift.String.self
            )
        }
    }

    public static func reverse(
        _ value: some QueryExpression<Swift.String>
    ) -> some QueryExpression<
        Swift.String
    > {
        SQLQueryExpression(
            "reverse(\(value.queryFragment))",
            as: Swift.String.self
        )
    }

    public static func `repeat`(
        _ value: some QueryExpression<Swift.String>,
        _ times: Int
    ) -> some QueryExpression<Swift.String> {
        SQLQueryExpression(
            "repeat(\(value.queryFragment), \(times))",
            as: Swift.String.self
        )
    }
}

extension QueryExpression where QueryValue == Swift.String {

    public func replacing(
        _ substring: Swift.String,
        with newSubstring: Swift.String
    )
        -> some QueryExpression<Swift.String>
    {
        PostgreSQL.String.replace(self, substring, newSubstring)
    }

    public func replace(
        _ other: some QueryExpression<QueryValue>,
        _ replacement: some QueryExpression<QueryValue>
    ) -> some QueryExpression<QueryValue> {
        PostgreSQL.String.replace(self, other, replacement)
    }

    public func translate(
        from: Swift.String,
        to: Swift.String
    ) -> some QueryExpression<
        Swift.String
    > {
        PostgreSQL.String.translate(self, from: from, to: to)
    }

    public func overlay(
        placing newSubstring: Swift.String,
        from position: Int,
        for length: Int? = nil
    ) -> some QueryExpression<Swift.String> {
        PostgreSQL.String.overlay(self, placing: newSubstring, from: position, for: length)
    }

    @_disfavoredOverload
    public func reversed() -> some QueryExpression<Swift.String> {
        PostgreSQL.String.reverse(self)
    }

    public func repeated(_ times: Int) -> some QueryExpression<Swift.String> {
        PostgreSQL.String.repeat(self, times)
    }
}
