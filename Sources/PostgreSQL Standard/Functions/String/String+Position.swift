import Foundation
import Structured_Queries_Primitives

extension PostgreSQL.String {

    public static func position(
        of substring: Swift.String,
        in value: some QueryExpression<Swift.String>
    ) -> some QueryExpression<Int> {
        SQLQueryExpression(
            "POSITION(\(bind: substring) IN \(value.queryFragment))",
            as: Int.self
        )
    }

    public static func strpos(
        _ value: some QueryExpression<Swift.String>,
        _ substring: Swift.String
    ) -> some QueryExpression<Int> {
        SQLQueryExpression(
            "STRPOS(\(value.queryFragment), \(bind: substring))",
            as: Int.self
        )
    }
}

extension QueryExpression where QueryValue == Swift.String {

    public func position(of substring: Swift.String) -> some QueryExpression<Int> {
        PostgreSQL.String.position(of: substring, in: self)
    }

    public func strpos(_ substring: Swift.String) -> some QueryExpression<Int> {
        PostgreSQL.String.strpos(self, substring)
    }
}
