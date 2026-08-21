import Foundation
import Structured_Queries_Primitives

extension PostgreSQL.String {

    public static func length(
        _ value: some QueryExpression<Swift.String>
    ) -> some QueryExpression<
        Int
    > {
        QueryFunction("length", value)
    }

    public static func length(
        _ value: some QueryExpression<Swift.String?>
    ) -> some QueryExpression<
        Int?
    > {
        QueryFunction("length", value)
    }

    public static func charLength(
        _ value: some QueryExpression<Swift.String>
    )
        -> some QueryExpression<Int>
    {
        SQLQueryExpression(
            "char_length(\(value.queryFragment))",
            as: Int.self
        )
    }

    public static func charLength(
        _ value: some QueryExpression<Swift.String?>
    )
        -> some QueryExpression<Int?>
    {
        SQLQueryExpression(
            "char_length(\(value.queryFragment))",
            as: Int?.self
        )
    }

    public static func bitLength(
        _ value: some QueryExpression<Swift.String>
    )
        -> some QueryExpression<
            Int
        >
    {
        SQLQueryExpression(
            "bit_length(\(value.queryFragment))",
            as: Int.self
        )
    }

    public static func bitLength(
        _ value: some QueryExpression<Swift.String?>
    )
        -> some QueryExpression<Int?>
    {
        SQLQueryExpression(
            "bit_length(\(value.queryFragment))",
            as: Int?.self
        )
    }

    public static func octetLength(
        _ value: some QueryExpression<Swift.String>
    )
        -> some QueryExpression<Int>
    {
        QueryFunction("octet_length", value)
    }

    public static func octetLength(
        _ value: some QueryExpression<Swift.String?>
    )
        -> some QueryExpression<Int?>
    {
        QueryFunction("octet_length", value)
    }
}

extension QueryExpression where QueryValue: Swift.Collection {

    public func length() -> some QueryExpression<Int> {
        QueryFunction("length", self)
    }
}

extension QueryExpression where QueryValue == Swift.String {

    public func charLength() -> some QueryExpression<Int> {
        PostgreSQL.String.charLength(self)
    }

    public func bitLength() -> some QueryExpression<Int> {
        PostgreSQL.String.bitLength(self)
    }

    public func octetLength() -> some QueryExpression<Int> {
        PostgreSQL.String.octetLength(self)
    }
}

extension QueryExpression where QueryValue == Swift.String? {

    public func length() -> some QueryExpression<Int?> {
        PostgreSQL.String.length(self)
    }

    public func charLength() -> some QueryExpression<Int?> {
        PostgreSQL.String.charLength(self)
    }

    public func bitLength() -> some QueryExpression<Int?> {
        PostgreSQL.String.bitLength(self)
    }

    public func octetLength() -> some QueryExpression<Int?> {
        PostgreSQL.String.octetLength(self)
    }
}
