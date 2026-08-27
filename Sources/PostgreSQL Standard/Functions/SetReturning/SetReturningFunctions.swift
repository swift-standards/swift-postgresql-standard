public import Foundation
import Structured_Queries

public func generateSeries(_ start: Int, _ stop: Int) -> SQLQueryExpression<Int> {
    SQLQueryExpression(
        "generate_series(\(start), \(stop))",
        as: Int.self
    )
}

public func generateSeries(_ start: Int, _ stop: Int, step: Int) -> SQLQueryExpression<Int> {
    SQLQueryExpression(
        "generate_series(\(start), \(stop), \(step))",
        as: Int.self
    )
}

public func generateSeriesTimestamp(
    _ start: Foundation.Date,
    _ stop: Foundation.Date,
    interval: String
)
    -> SQLQueryExpression<Date>
{
    SQLQueryExpression(
        "generate_series(\(bind: start), \(bind: stop), '\(raw: interval)'::interval)",
        as: Foundation.Date.self
    )
}

public func generateSubscripts<Element>(
    _ array: some QueryExpression<[Element]>,
    dimension: Int = 1
) -> SQLQueryExpression<Int> where Element: QueryBindable {
    SQLQueryExpression(
        "generate_subscripts(\(array.queryFragment), \(dimension))",
        as: Int.self
    )
}

public func generateSubscripts<Element>(
    _ array: some QueryExpression<[Element]>,
    dimension: Int = 1,
    reverse: Bool
) -> SQLQueryExpression<Int> where Element: QueryBindable {
    SQLQueryExpression(
        "generate_subscripts(\(array.queryFragment), \(dimension), \(reverse))",
        as: Int.self
    )
}

public func jsonArrayElements(_ json: some QueryExpression<Data>) -> SQLQueryExpression<Data> {
    SQLQueryExpression(
        "json_array_elements(\(json.queryFragment))",
        as: Foundation.Data.self
    )
}

public func jsonArrayElementsText(_ json: some QueryExpression<Data>) -> SQLQueryExpression<String>
{
    SQLQueryExpression(
        "json_array_elements_text(\(json.queryFragment))",
        as: String.self
    )
}

public func jsonbArrayElements(_ jsonb: some QueryExpression<Data>) -> SQLQueryExpression<Data> {
    SQLQueryExpression(
        "jsonb_array_elements(\(jsonb.queryFragment))",
        as: Foundation.Data.self
    )
}

public func jsonbArrayElementsText(
    _ jsonb: some QueryExpression<Data>
) -> SQLQueryExpression<
    String
> {
    SQLQueryExpression(
        "jsonb_array_elements_text(\(jsonb.queryFragment))",
        as: String.self
    )
}

extension QueryExpression where QueryValue == String {

    public func regexpMatches(
        _ pattern: String,
        flags: String = "g"
    ) -> some QueryExpression<
        [String]
    > {
        SQLQueryExpression(
            "regexp_matches(\(self.queryFragment), \(bind: pattern), \(bind: flags))",
            as: [String].self
        )
    }
}

extension QueryExpression where QueryValue == String {

    public func regexpSplitToTable(
        _ pattern: String,
        flags: String? = nil
    ) -> some QueryExpression<
        String
    > {
        if let flags {
            return SQLQueryExpression(
                "regexp_split_to_table(\(self.queryFragment), \(bind: pattern), \(bind: flags))",
                as: String.self
            )
        } else {
            return SQLQueryExpression(
                "regexp_split_to_table(\(self.queryFragment), \(bind: pattern))",
                as: String.self
            )
        }
    }
}
