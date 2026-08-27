import Foundation
import Structured_Queries

extension PostgreSQL.String {

    public static func quote(
        _ value: some QueryExpression<Swift.String>
    ) -> some QueryExpression<
        Swift.String
    > {
        QueryFunction("quote", value)
    }

    public static func quote(
        _ value: some QueryExpression<Swift.String?>
    ) -> some QueryExpression<
        Swift.String?
    > {
        QueryFunction("quote", value)
    }

    public static func quoteLiteral(
        _ value: some QueryExpression<Swift.String>
    )
        -> some QueryExpression<Swift.String>
    {
        SQLQueryExpression(
            "QUOTE_LITERAL(\(value.queryFragment))",
            as: Swift.String.self
        )
    }

    public static func quoteIdent(
        _ value: some QueryExpression<Swift.String>
    )
        -> some QueryExpression<Swift.String>
    {
        SQLQueryExpression(
            "QUOTE_IDENT(\(value.queryFragment))",
            as: Swift.String.self
        )
    }
}

extension QueryExpression where QueryValue: _OptionalPromotable<Swift.String?> {

    public func quote() -> some QueryExpression<QueryValue> {
        QueryFunction("quote", self)
    }
}

extension QueryExpression where QueryValue == Swift.String {

    public func quoteLiteral() -> some QueryExpression<Swift.String> {
        PostgreSQL.String.quoteLiteral(self)
    }

    public func quoteIdent() -> some QueryExpression<Swift.String> {
        PostgreSQL.String.quoteIdent(self)
    }
}
