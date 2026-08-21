import Foundation
import Structured_Queries_Primitives

extension QueryExpression where QueryValue: Swift.Collection, QueryValue.Element: QueryBindable {

    public func appending(_ element: QueryValue.Element) -> some QueryExpression<QueryValue> {
        SQLQueryExpression(
            "array_append(\(self.queryFragment), \(bind: element))",
            as: QueryValue.self
        )
    }

    public func prepending(_ element: QueryValue.Element) -> some QueryExpression<QueryValue> {
        SQLQueryExpression(
            "array_prepend(\(bind: element), \(self.queryFragment))",
            as: QueryValue.self
        )
    }

    public func concatenating(
        _ other: some QueryExpression<QueryValue>
    ) -> some QueryExpression<
        QueryValue
    > {
        SQLQueryExpression(
            "array_cat(\(self.queryFragment), \(other.queryFragment))",
            as: QueryValue.self
        )
    }

    public func concatenating(_ elements: [QueryValue.Element]) -> some QueryExpression<QueryValue>
    {

        var fragments: [QueryFragment] = []
        for element in elements {
            fragments.append("\(bind: element)")
        }
        let arrayLiteral = "ARRAY[\(fragments.joined(separator: ", "))]"
        return SQLQueryExpression(
            "array_cat(\(self.queryFragment), \(raw: arrayLiteral))",
            as: QueryValue.self
        )
    }
}

public func append<Element>(
    _ array: some QueryExpression<[Element]>,
    _ element: Element
) -> some QueryExpression<[Element]> where Element: QueryBindable {
    SQLQueryExpression(
        "array_append(\(array.queryFragment), \(bind: element))",
        as: [Element].self
    )
}

public func prepend<Element>(
    _ element: Element,
    to array: some QueryExpression<[Element]>
) -> some QueryExpression<[Element]> where Element: QueryBindable {
    SQLQueryExpression(
        "array_prepend(\(bind: element), \(array.queryFragment))",
        as: [Element].self
    )
}

public func concatenate<Element>(
    _ array1: some QueryExpression<[Element]>,
    _ array2: some QueryExpression<[Element]>
) -> some QueryExpression<[Element]> where Element: QueryBindable {
    SQLQueryExpression(
        "array_cat(\(array1.queryFragment), \(array2.queryFragment))",
        as: [Element].self
    )
}

public func array<Element>(
    _ elements: [Element]
) -> some QueryExpression<[Element]> where Element: QueryBindable {

    var fragments: [QueryFragment] = []
    for element in elements {
        fragments.append("\(bind: element)")
    }
    let arrayLiteral = QueryFragment("ARRAY[\(fragments.joined(separator: ", "))]")
    return SQLQueryExpression(arrayLiteral, as: [Element].self)
}

public func emptyArray<Element>(
    of elementType: Element.Type
) -> some QueryExpression<[Element]> where Element: PostgreSQLType {

    return SQLQueryExpression(
        "ARRAY[]::\(raw: Element.typeName)[]",
        as: [Element].self
    )
}
