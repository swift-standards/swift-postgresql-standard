import Foundation
import Structured_Queries

extension PostgreSQL.String {

    public static func substring(
        _ value: some QueryExpression<Swift.String>,
        from start: Int,
        for length: Int? = nil
    ) -> some QueryExpression<Swift.String> {
        if let length {
            return SQLQueryExpression(
                "SUBSTRING(\(value.queryFragment) FROM \(start) FOR \(length))",
                as: Swift.String.self
            )
        } else {
            return SQLQueryExpression(
                "SUBSTRING(\(value.queryFragment) FROM \(start))",
                as: Swift.String.self
            )
        }
    }

    public static func substr(
        _ value: some QueryExpression<Swift.String>,
        _ offset: Int,
        _ length: Int? = nil
    ) -> some QueryExpression<Swift.String> {
        if let length {
            return QueryFunction("substr", value, offset, length)
        } else {
            return QueryFunction("substr", value, offset)
        }
    }

    public static func substr(
        _ value: some QueryExpression<Swift.String>,
        _ offset: some QueryExpression<Int>,
        _ length: (some QueryExpression<Int>)? = Int?.none
    ) -> some QueryExpression<Swift.String> {
        if let length {
            return QueryFunction("substr", value, offset, length)
        } else {
            return QueryFunction("substr", value, offset)
        }
    }

    public static func left(
        _ value: some QueryExpression<Swift.String>,
        _ n: Int
    ) -> some QueryExpression<Swift.String> {
        SQLQueryExpression(
            "left(\(value.queryFragment), \(n))",
            as: Swift.String.self
        )
    }

    public static func right(
        _ value: some QueryExpression<Swift.String>,
        _ n: Int
    ) -> some QueryExpression<Swift.String> {
        SQLQueryExpression(
            "right(\(value.queryFragment), \(n))",
            as: Swift.String.self
        )
    }

    public static func splitPart(
        _ value: some QueryExpression<Swift.String>,
        delimiter: Swift.String,
        field: Int
    ) -> some QueryExpression<Swift.String> {
        SQLQueryExpression(
            "split_part(\(value.queryFragment), \(bind: delimiter), \(field))",
            as: Swift.String.self
        )
    }
}

extension QueryExpression where QueryValue == Swift.String {

    public func substring(
        from start: Int,
        for length: Int? = nil
    ) -> some QueryExpression<
        Swift.String
    > {
        PostgreSQL.String.substring(self, from: start, for: length)
    }

    public func substr(
        _ offset: some QueryExpression<Int>,
        _ length: (some QueryExpression<Int>)? = Int?.none
    ) -> some QueryExpression<QueryValue> {
        PostgreSQL.String.substr(self, offset, length)
    }

    public func left(_ n: Int) -> some QueryExpression<Swift.String> {
        PostgreSQL.String.left(self, n)
    }

    public func right(_ n: Int) -> some QueryExpression<Swift.String> {
        PostgreSQL.String.right(self, n)
    }

    public func splitPart(delimiter: Swift.String, field: Int) -> some QueryExpression<Swift.String>
    {
        PostgreSQL.String.splitPart(self, delimiter: delimiter, field: field)
    }
}
