import Foundation
import Structured_Queries

extension PostgreSQL.String {

    public static func ltrim(
        _ value: some QueryExpression<Swift.String>,
        characters: Swift.String = " "
    ) -> some QueryExpression<Swift.String> {
        SQLQueryExpression(
            "ltrim(\(value.queryFragment), \(bind: characters))",
            as: Swift.String.self
        )
    }

    public static func ltrim(
        _ value: some QueryExpression<Swift.String>,
        characters: some QueryExpression<Swift.String>
    ) -> some QueryExpression<Swift.String> {
        QueryFunction("ltrim", value, characters)
    }

    public static func rtrim(
        _ value: some QueryExpression<Swift.String>,
        characters: Swift.String = " "
    ) -> some QueryExpression<Swift.String> {
        SQLQueryExpression(
            "rtrim(\(value.queryFragment), \(bind: characters))",
            as: Swift.String.self
        )
    }

    public static func rtrim(
        _ value: some QueryExpression<Swift.String>,
        characters: some QueryExpression<Swift.String>
    ) -> some QueryExpression<Swift.String> {
        QueryFunction("rtrim", value, characters)
    }

    public static func btrim(
        _ value: some QueryExpression<Swift.String>,
        characters: Swift.String = " "
    ) -> some QueryExpression<Swift.String> {
        SQLQueryExpression(
            "btrim(\(value.queryFragment), \(bind: characters))",
            as: Swift.String.self
        )
    }

    public static func btrim(
        _ value: some QueryExpression<Swift.String>,
        characters: some QueryExpression<Swift.String>
    ) -> some QueryExpression<Swift.String> {
        QueryFunction("trim", value, characters)
    }
}

extension QueryExpression where QueryValue == Swift.String {

    public func ltrim(
        _ characters: (some QueryExpression<QueryValue>)? = QueryValue?.none
    ) -> some QueryExpression<Swift.String> {
        if let characters {
            return SQLQueryExpression(
                "ltrim(\(self.queryFragment), \(characters.queryFragment))",
                as: Swift.String.self
            )
        } else {
            return SQLQueryExpression("ltrim(\(self.queryFragment))", as: Swift.String.self)
        }
    }

    public func ltrim(characters: Swift.String) -> some QueryExpression<Swift.String> {
        PostgreSQL.String.ltrim(self, characters: characters)
    }

    public func rtrim(
        _ characters: (some QueryExpression<QueryValue>)? = QueryValue?.none
    ) -> some QueryExpression<Swift.String> {
        if let characters {
            return SQLQueryExpression(
                "rtrim(\(self.queryFragment), \(characters.queryFragment))",
                as: Swift.String.self
            )
        } else {
            return SQLQueryExpression("rtrim(\(self.queryFragment))", as: Swift.String.self)
        }
    }

    public func rtrim(characters: Swift.String) -> some QueryExpression<Swift.String> {
        PostgreSQL.String.rtrim(self, characters: characters)
    }

    public func trim(
        _ characters: (some QueryExpression<QueryValue>)? = QueryValue?.none
    ) -> some QueryExpression<Swift.String> {
        if let characters {
            return SQLQueryExpression(
                "trim(\(self.queryFragment), \(characters.queryFragment))",
                as: Swift.String.self
            )
        } else {
            return SQLQueryExpression("trim(\(self.queryFragment))", as: Swift.String.self)
        }
    }

    public func btrim(characters: Swift.String) -> some QueryExpression<Swift.String> {
        PostgreSQL.String.btrim(self, characters: characters)
    }
}
