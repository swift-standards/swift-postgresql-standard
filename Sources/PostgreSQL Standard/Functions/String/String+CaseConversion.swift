import Foundation
import Structured_Queries_Primitives

extension PostgreSQL.String {

    public static func upper(
        _ value: some QueryExpression<Swift.String>
    ) -> some QueryExpression<
        Swift.String
    > {
        SQLQueryExpression(
            "upper(\(value.queryFragment))",
            as: Swift.String.self
        )
    }

    public static func upper(
        _ value: some QueryExpression<Swift.String?>
    ) -> some QueryExpression<
        Swift.String?
    > {
        SQLQueryExpression(
            "upper(\(value.queryFragment))",
            as: Swift.String?.self
        )
    }

    public static func lower(
        _ value: some QueryExpression<Swift.String>
    ) -> some QueryExpression<
        Swift.String
    > {
        SQLQueryExpression(
            "lower(\(value.queryFragment))",
            as: Swift.String.self
        )
    }

    public static func lower(
        _ value: some QueryExpression<Swift.String?>
    ) -> some QueryExpression<
        Swift.String?
    > {
        SQLQueryExpression(
            "lower(\(value.queryFragment))",
            as: Swift.String?.self
        )
    }

    public static func initcap(
        _ value: some QueryExpression<Swift.String>
    ) -> some QueryExpression<
        Swift.String
    > {
        SQLQueryExpression(
            "initcap(\(value.queryFragment))",
            as: Swift.String.self
        )
    }

    public static func initcap(
        _ value: some QueryExpression<Swift.String?>
    )
        -> some QueryExpression<
            Swift.String?
        >
    {
        SQLQueryExpression(
            "initcap(\(value.queryFragment))",
            as: Swift.String?.self
        )
    }
}

extension QueryExpression where QueryValue == Swift.String {

    @_disfavoredOverload
    public func uppercased() -> some QueryExpression<Swift.String> {
        PostgreSQL.String.upper(self)
    }

    @_disfavoredOverload
    public func lowercased() -> some QueryExpression<Swift.String> {
        PostgreSQL.String.lower(self)
    }

    public func initcap() -> some QueryExpression<Swift.String> {
        PostgreSQL.String.initcap(self)
    }
}

extension QueryExpression where QueryValue == Swift.String? {

    public func uppercased() -> some QueryExpression<Swift.String?> {
        PostgreSQL.String.upper(self)
    }

    public func lowercased() -> some QueryExpression<Swift.String?> {
        PostgreSQL.String.lower(self)
    }

    public func initcap() -> some QueryExpression<Swift.String?> {
        PostgreSQL.String.initcap(self)
    }
}
