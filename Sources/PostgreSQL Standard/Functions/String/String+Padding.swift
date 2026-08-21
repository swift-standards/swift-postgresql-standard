import Foundation
import Structured_Queries_Primitives

extension PostgreSQL.String {

    public static func lpad(
        _ value: some QueryExpression<Swift.String>,
        to length: Int,
        with fill: Swift.String = " "
    ) -> some QueryExpression<Swift.String> {
        SQLQueryExpression(
            "lpad(\(value.queryFragment), \(length), \(bind: fill))",
            as: Swift.String.self
        )
    }

    public static func rpad(
        _ value: some QueryExpression<Swift.String>,
        to length: Int,
        with fill: Swift.String = " "
    ) -> some QueryExpression<Swift.String> {
        SQLQueryExpression(
            "rpad(\(value.queryFragment), \(length), \(bind: fill))",
            as: Swift.String.self
        )
    }
}

extension QueryExpression where QueryValue == Swift.String {

    public func lpad(
        to length: Int,
        with fill: Swift.String = " "
    ) -> some QueryExpression<
        Swift.String
    > {
        PostgreSQL.String.lpad(self, to: length, with: fill)
    }

    public func rpad(
        to length: Int,
        with fill: Swift.String = " "
    ) -> some QueryExpression<
        Swift.String
    > {
        PostgreSQL.String.rpad(self, to: length, with: fill)
    }
}
