public import Foundation
import Structured_Queries

extension QueryExpression where QueryValue: Swift.Collection, QueryValue.Element: QueryBindable {

    public func removing(_ element: QueryValue.Element) -> some QueryExpression<QueryValue> {
        SQLQueryExpression(
            "array_remove(\(self.queryFragment), \(bind: element))",
            as: QueryValue.self
        )
    }

    public func replacing(
        _ element: QueryValue.Element,
        with replacement: QueryValue.Element
    )
        -> some QueryExpression<QueryValue>
    {
        SQLQueryExpression(
            "array_replace(\(self.queryFragment), \(bind: element), \(bind: replacement))",
            as: QueryValue.self
        )
    }

    @_disfavoredOverload
    public func joined(separator: String) -> some QueryExpression<String> {
        SQLQueryExpression(
            "array_to_string(\(self.queryFragment), \(bind: separator))",
            as: String.self
        )
    }

    @_disfavoredOverload
    public func joined(separator: String, nullReplacement: String) -> some QueryExpression<String> {
        SQLQueryExpression(
            "array_to_string(\(self.queryFragment), \(bind: separator), \(bind: nullReplacement))",
            as: String.self
        )
    }

    public var dimensions: some QueryExpression<String?> {
        SQLQueryExpression(
            "array_dims(\(self.queryFragment))",
            as: String?.self
        )
    }

    public func toJSON() -> some QueryExpression<Foundation.Data> {
        SQLQueryExpression(
            "array_to_json(\(self.queryFragment))",
            as: Foundation.Data.self
        )
    }

    public func toJSON(prettyPrint: Bool) -> some QueryExpression<Foundation.Data> {
        SQLQueryExpression(
            "array_to_json(\(self.queryFragment), \(prettyPrint))",
            as: Foundation.Data.self
        )
    }
}

extension QueryExpression where QueryValue == String {

    public func split(separator: String) -> some QueryExpression<[String]> {
        SQLQueryExpression(
            "string_to_array(\(self.queryFragment), \(bind: separator))",
            as: [String].self
        )
    }

    public func split(separator: String, nullString: String) -> some QueryExpression<[String]> {
        SQLQueryExpression(
            "string_to_array(\(self.queryFragment), \(bind: separator), \(bind: nullString))",
            as: [String].self
        )
    }
}

public func split(
    _ string: some QueryExpression<String>,
    separator: String
) -> some QueryExpression<[String]> {
    SQLQueryExpression(
        "string_to_array(\(string.queryFragment), \(bind: separator))",
        as: [String].self
    )
}

public func split(
    _ string: some QueryExpression<String>,
    separator: String,
    nullString: String
) -> some QueryExpression<[String]> {
    SQLQueryExpression(
        "string_to_array(\(string.queryFragment), \(bind: separator), \(bind: nullString))",
        as: [String].self
    )
}

public func fill<Element>(
    value: Element,
    count: Int
) -> some QueryExpression<[Element]> where Element: QueryBindable {
    return SQLQueryExpression(
        "array_fill(\(bind: value), ARRAY[\(count)])",
        as: [Element].self
    )
}

public func fill<Element>(
    value: Element,
    lengths: [Int]
) -> some QueryExpression<[Element]> where Element: QueryBindable {
    let lengthsList = lengths.map(String.init).joined(separator: ", ")
    return SQLQueryExpression(
        "array_fill(\(bind: value), ARRAY[\(raw: lengthsList)])",
        as: [Element].self
    )
}

public func fill<Element>(
    value: Element,
    lengths: [Int],
    lowerBounds: [Int]
) -> some QueryExpression<[Element]> where Element: QueryBindable {

    let lengthsList: String = lengths.map(String.init).joined(separator: ", ")
    let boundsList: String = lowerBounds.map(String.init).joined(separator: ", ")
    return SQLQueryExpression(
        "array_fill(\(bind: value), ARRAY[\(raw: lengthsList)], ARRAY[\(raw: boundsList)])",
        as: [Element].self
    )
}
