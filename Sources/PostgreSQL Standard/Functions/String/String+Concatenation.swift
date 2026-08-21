import Foundation
import Structured_Queries_Primitives

extension PostgreSQL.String {

    public static func concat(
        _ value: some QueryExpression<Swift.String>,
        _ other: Swift.String
    ) -> some QueryExpression<Swift.String> {
        SQLQueryExpression(
            "(\(value.queryFragment) || \(bind: other))",
            as: Swift.String.self
        )
    }

    public static func concat(
        _ value: some QueryExpression<Swift.String>,
        _ other: some QueryExpression<Swift.String>
    ) -> some QueryExpression<Swift.String> {
        SQLQueryExpression(
            "(\(value.queryFragment) || \(other.queryFragment))",
            as: Swift.String.self
        )
    }

    public static func concatWithSeparator(
        _ separator: Swift.String,
        _ s1: some QueryExpression<Swift.String?>
    ) -> some QueryExpression<Swift.String> {
        SQLQueryExpression(
            "concat_ws(\(bind: separator), \(s1.queryFragment))",
            as: Swift.String.self
        )
    }

    public static func concatWithSeparator(
        _ separator: Swift.String,
        _ s1: some QueryExpression<Swift.String?>,
        _ s2: some QueryExpression<Swift.String?>
    ) -> some QueryExpression<Swift.String> {
        SQLQueryExpression(
            "concat_ws(\(bind: separator), \(s1.queryFragment), \(s2.queryFragment))",
            as: Swift.String.self
        )
    }

    public static func concatWithSeparator(
        _ separator: Swift.String,
        _ s1: some QueryExpression<Swift.String?>,
        _ s2: some QueryExpression<Swift.String?>,
        _ s3: some QueryExpression<Swift.String?>
    ) -> some QueryExpression<Swift.String> {
        SQLQueryExpression(
            "concat_ws(\(bind: separator), \(s1.queryFragment), \(s2.queryFragment), \(s3.queryFragment))",
            as: Swift.String.self
        )
    }

    public static func concatWithSeparator(
        _ separator: Swift.String,
        _ s1: some QueryExpression<Swift.String?>,
        _ s2: some QueryExpression<Swift.String?>,
        _ s3: some QueryExpression<Swift.String?>,
        _ s4: some QueryExpression<Swift.String?>
    ) -> some QueryExpression<Swift.String> {
        SQLQueryExpression(
            "concat_ws(\(bind: separator), \(s1.queryFragment), \(s2.queryFragment), \(s3.queryFragment), \(s4.queryFragment))",
            as: Swift.String.self
        )
    }
}

extension QueryExpression where QueryValue == Swift.String {

    public func concat(_ other: Swift.String) -> some QueryExpression<Swift.String> {
        PostgreSQL.String.concat(self, other)
    }

    public func concat(
        _ other: some QueryExpression<Swift.String>
    ) -> some QueryExpression<
        Swift.String
    > {
        PostgreSQL.String.concat(self, other)
    }
}

public func concatWithSeparator(
    _ separator: Swift.String,
    _ s1: some QueryExpression<Swift.String?>
) -> some QueryExpression<Swift.String> {
    PostgreSQL.String.concatWithSeparator(separator, s1)
}

public func concatWithSeparator(
    _ separator: Swift.String,
    _ s1: some QueryExpression<Swift.String?>,
    _ s2: some QueryExpression<Swift.String?>
) -> some QueryExpression<Swift.String> {
    PostgreSQL.String.concatWithSeparator(separator, s1, s2)
}

public func concatWithSeparator(
    _ separator: Swift.String,
    _ s1: some QueryExpression<Swift.String?>,
    _ s2: some QueryExpression<Swift.String?>,
    _ s3: some QueryExpression<Swift.String?>
) -> some QueryExpression<Swift.String> {
    PostgreSQL.String.concatWithSeparator(separator, s1, s2, s3)
}

public func concatWithSeparator(
    _ separator: Swift.String,
    _ s1: some QueryExpression<Swift.String?>,
    _ s2: some QueryExpression<Swift.String?>,
    _ s3: some QueryExpression<Swift.String?>,
    _ s4: some QueryExpression<Swift.String?>
) -> some QueryExpression<Swift.String> {
    PostgreSQL.String.concatWithSeparator(separator, s1, s2, s3, s4)
}
