public import Foundation
public import Structured_Queries_Primitives

extension QueryExpression where QueryValue == Date {

    public func toChar(_ format: String) -> some QueryExpression<String> {
        SQLQueryExpression(
            "to_char(\(self.queryFragment), \(bind: format))",
            as: String.self
        )
    }
}

extension QueryExpression where QueryValue: Numeric & QueryBindable {

    public func toChar(_ format: String) -> some QueryExpression<String> {
        SQLQueryExpression(
            "to_char(\(self.queryFragment), \(bind: format))",
            as: String.self
        )
    }
}

extension QueryExpression where QueryValue == Int {

    public func toChar(_ format: String) -> some QueryExpression<String> {
        SQLQueryExpression(
            "to_char(\(self.queryFragment), \(bind: format))",
            as: String.self
        )
    }
}

extension QueryExpression where QueryValue == Double {

    public func toChar(_ format: String) -> some QueryExpression<String> {
        SQLQueryExpression(
            "to_char(\(self.queryFragment), \(bind: format))",
            as: String.self
        )
    }
}

extension QueryExpression where QueryValue == String {

    public func toDate(format: String) -> some QueryExpression<Date> {
        SQLQueryExpression(
            "to_date(\(self.queryFragment), \(bind: format))",
            as: Date.self
        )
    }

    public func toTimestamp(format: String) -> some QueryExpression<Date> {
        SQLQueryExpression(
            "to_timestamp(\(self.queryFragment), \(bind: format))",
            as: Date.self
        )
    }
}

public func toTimestamp(_ unixTimestamp: some QueryExpression<Double>) -> some QueryExpression<Date>
{
    SQLQueryExpression(
        "to_timestamp(\(unixTimestamp.queryFragment))",
        as: Date.self
    )
}

extension QueryExpression where QueryValue == String {

    public func toNumber(format: String) -> some QueryExpression<Double> {
        SQLQueryExpression(
            "to_number(\(self.queryFragment), \(bind: format))",
            as: Double.self
        )
    }
}

extension QueryExpression where QueryValue == Date {

    public func age() -> some QueryExpression<String> {
        SQLQueryExpression(
            "age(\(self.queryFragment))",
            as: String.self
        )
    }

    public func age(from: Date) -> some QueryExpression<String> {
        SQLQueryExpression(
            "age(\(self.queryFragment), \(bind: from))",
            as: String.self
        )
    }

    public func age(from: some QueryExpression<Date>) -> some QueryExpression<String> {
        SQLQueryExpression(
            "age(\(self.queryFragment), \(from.queryFragment))",
            as: String.self
        )
    }
}

extension QueryExpression where QueryValue == String {

    public func justifyDays() -> some QueryExpression<String> {
        SQLQueryExpression(
            "justify_days(\(self.queryFragment))",
            as: String.self
        )
    }

    public func justifyHours() -> some QueryExpression<String> {
        SQLQueryExpression(
            "justify_hours(\(self.queryFragment))",
            as: String.self
        )
    }

    public func justifyInterval() -> some QueryExpression<String> {
        SQLQueryExpression(
            "justify_interval(\(self.queryFragment))",
            as: String.self
        )
    }
}
