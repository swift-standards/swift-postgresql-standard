import Foundation
import Structured_Queries_Primitives

extension PostgreSQL.String {

    public static func chr(_ code: Int) -> some QueryExpression<Swift.String> {
        SQLQueryExpression(
            "chr(\(code))",
            as: Swift.String.self
        )
    }

    public static func ascii(
        _ value: some QueryExpression<Swift.String>
    ) -> some QueryExpression<
        Int?
    > {
        SQLQueryExpression(
            "ASCII(\(value.queryFragment))",
            as: Int?.self
        )
    }

    public static func md5(
        _ value: some QueryExpression<Swift.String>
    ) -> some QueryExpression<
        Swift.String
    > {
        SQLQueryExpression(
            "md5(\(value.queryFragment))",
            as: Swift.String.self
        )
    }
}

extension QueryExpression where QueryValue == Swift.String {

    public static func chr(_ code: Int) -> some QueryExpression<Swift.String> {
        PostgreSQL.String.chr(code)
    }

    public func ascii() -> some QueryExpression<Int?> {
        PostgreSQL.String.ascii(self)
    }

    public func md5() -> some QueryExpression<Swift.String> {
        PostgreSQL.String.md5(self)
    }
}
