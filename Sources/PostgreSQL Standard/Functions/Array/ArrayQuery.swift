import Foundation
import Structured_Queries_Primitives

extension QueryExpression where QueryValue: Swift.Collection, QueryValue.Element: QueryBindable {

    public func arrayLength() -> some QueryExpression<Int?> {
        SQLQueryExpression(
            "array_length(\(self.queryFragment), 1)",
            as: Int?.self
        )
    }

    public func cardinality() -> some QueryExpression<Int?> {
        SQLQueryExpression(
            "cardinality(\(self.queryFragment))",
            as: Int?.self
        )
    }

    public func arrayPosition(_ element: QueryValue.Element) -> some QueryExpression<Int?> {
        SQLQueryExpression(
            "array_position(\(self.queryFragment), \(bind: element))",
            as: Int?.self
        )
    }

    public func arrayPosition(
        _ element: QueryValue.Element,
        startingFrom start: Int
    )
        -> some QueryExpression<Int?>
    {
        SQLQueryExpression(
            "array_position(\(self.queryFragment), \(bind: element), \(start))",
            as: Int?.self
        )
    }

    public func arrayPositions(_ element: QueryValue.Element) -> some QueryExpression<[Int]> {
        SQLQueryExpression(
            "array_positions(\(self.queryFragment), \(bind: element))",
            as: [Int].self
        )
    }

    public func arrayLower() -> some QueryExpression<Int?> {
        SQLQueryExpression(
            "array_lower(\(self.queryFragment), 1)",
            as: Int?.self
        )
    }

    public func arrayUpper() -> some QueryExpression<Int?> {
        SQLQueryExpression(
            "array_upper(\(self.queryFragment), 1)",
            as: Int?.self
        )
    }

    public func arrayNdims() -> some QueryExpression<Int?> {
        SQLQueryExpression(
            "array_ndims(\(self.queryFragment))",
            as: Int?.self
        )
    }
}

public func unnest<Element>(
    _ array: some QueryExpression<[Element]>
) -> some QueryExpression<Element> where Element: QueryBindable {
    SQLQueryExpression(
        "unnest(\(array.queryFragment))",
        as: Element.self
    )
}

public func unnestArrays<Element1, Element2>(
    _ array1: some QueryExpression<[Element1]>,
    _ array2: some QueryExpression<[Element2]>
) -> SQLQueryExpression<(Element1, Element2)>
where Element1: QueryBindable, Element2: QueryBindable {
    SQLQueryExpression(
        "unnest(\(array1.queryFragment), \(array2.queryFragment))",
        as: (Element1, Element2).self
    )
}
