public import Foundation
import Structured_Queries_Primitives

extension QueryExpression where QueryValue == Bool {

    public func toJSONBoolean() -> some QueryExpression<String> {
        SQLQueryExpression(
            "CASE WHEN \(self.queryFragment) THEN 'true' ELSE 'false' END",
            as: String.self
        )
    }
}

extension QueryExpression where QueryValue == String {

    public func jsonQuote() -> some QueryExpression<Data> {
        SQLQueryExpression("to_json(\(self.queryFragment))", as: Foundation.Data.self)
    }
}

extension QueryExpression where QueryValue == String? {

    public func jsonQuote() -> some QueryExpression<Data?> {
        SQLQueryExpression("to_json(\(self.queryFragment))", as: Foundation.Data?.self)
    }
}

extension QueryExpression {

    public func jsonQuote() -> some QueryExpression<Data> {
        SQLQueryExpression("to_json(\(self.queryFragment))", as: Foundation.Data.self)
    }
}
