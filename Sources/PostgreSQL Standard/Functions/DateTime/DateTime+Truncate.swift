public import Foundation
public import Structured_Queries_Primitives

public enum DateTruncPrecision: String {
    case year
    case month
    case day
    case hour
    case minute
    case second
}

extension QueryExpression where QueryValue == Date {

    public func dateTrunc(_ precision: DateTruncPrecision) -> some QueryExpression<Date> {
        SQLQueryExpression(
            "DATE_TRUNC('\(raw: precision.rawValue)', \(self.queryFragment))",
            as: Date.self
        )
    }
}
