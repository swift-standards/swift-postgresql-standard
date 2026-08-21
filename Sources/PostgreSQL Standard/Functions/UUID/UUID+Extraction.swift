public import Foundation
public import Structured_Queries_Primitives

extension QueryExpression where QueryValue == UUID {

    public func extractVersion() -> some QueryExpression<Int?> {
        SQLQueryExpression(
            "uuid_extract_version(\(self.queryFragment))",
            as: Int?.self
        )
    }

    public func extractTimestamp() -> some QueryExpression<Date?> {
        SQLQueryExpression(
            "uuid_extract_timestamp(\(self.queryFragment))",
            as: Date?.self
        )
    }
}

extension QueryExpression where QueryValue == UUID? {

    public func extractVersion() -> some QueryExpression<Int?> {
        SQLQueryExpression(
            "uuid_extract_version(\(self.queryFragment))",
            as: Int?.self
        )
    }

    public func extractTimestamp() -> some QueryExpression<Date?> {
        SQLQueryExpression(
            "uuid_extract_timestamp(\(self.queryFragment))",
            as: Date?.self
        )
    }
}
