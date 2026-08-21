import Foundation
import Structured_Queries_Primitives

extension QueryExpression where QueryValue: Swift.Collection, QueryValue.Element: QueryBindable {

    public func contains(_ other: [QueryValue.Element]) -> some QueryExpression<Bool> {
        var fragment: QueryFragment = "(\(self.queryFragment) @> ARRAY["
        fragment.append(other.map { "\(bind: $0)" }.joined(separator: ", "))
        fragment.append("])")
        return SQLQueryExpression(fragment, as: Bool.self)
    }

    public func contains(_ other: some QueryExpression<QueryValue>) -> some QueryExpression<Bool> {
        SQLQueryExpression(
            "(\(self.queryFragment) @> \(other.queryFragment))",
            as: Bool.self
        )
    }

    public func isContainedBy(_ other: [QueryValue.Element]) -> some QueryExpression<Bool> {
        var fragment: QueryFragment = "(\(self.queryFragment) <@ ARRAY["
        fragment.append(other.map { "\(bind: $0)" }.joined(separator: ", "))
        fragment.append("])")
        return SQLQueryExpression(fragment, as: Bool.self)
    }

    public func isContainedBy(
        _ other: some QueryExpression<QueryValue>
    ) -> some QueryExpression<
        Bool
    > {
        SQLQueryExpression(
            "(\(self.queryFragment) <@ \(other.queryFragment))",
            as: Bool.self
        )
    }

    public func overlaps(_ other: [QueryValue.Element]) -> some QueryExpression<Bool> {
        var fragment: QueryFragment = "(\(self.queryFragment) && ARRAY["
        fragment.append(other.map { "\(bind: $0)" }.joined(separator: ", "))
        fragment.append("])")
        return SQLQueryExpression(fragment, as: Bool.self)
    }

    public func overlaps(_ other: some QueryExpression<QueryValue>) -> some QueryExpression<Bool> {
        SQLQueryExpression(
            "(\(self.queryFragment) && \(other.queryFragment))",
            as: Bool.self
        )
    }

    public func arrayConcat(_ other: [QueryValue.Element]) -> some QueryExpression<QueryValue> {
        var fragment: QueryFragment = "(\(self.queryFragment) || ARRAY["
        fragment.append(other.map { "\(bind: $0)" }.joined(separator: ", "))
        fragment.append("])")
        return SQLQueryExpression(fragment, as: QueryValue.self)
    }

    public func arrayConcat(
        _ other: some QueryExpression<QueryValue>
    ) -> some QueryExpression<
        QueryValue
    > {
        SQLQueryExpression(
            "(\(self.queryFragment) || \(other.queryFragment))",
            as: QueryValue.self
        )
    }

    public func arrayConcat(_ element: QueryValue.Element) -> some QueryExpression<QueryValue> {
        SQLQueryExpression(
            "(\(self.queryFragment) || \(bind: element))",
            as: QueryValue.self
        )
    }
}

public func prependToArray<Element>(
    _ element: Element,
    _ array: some QueryExpression<[Element]>
) -> some QueryExpression<[Element]> where Element: QueryBindable {
    SQLQueryExpression(
        "(\(bind: element) || \(array.queryFragment))",
        as: [Element].self
    )
}

extension QueryExpression
where QueryValue: Swift.Collection, QueryValue.Element: QueryBindable & Equatable {

    public func arrayEquals(_ other: [QueryValue.Element]) -> some QueryExpression<Bool> {
        var fragment: QueryFragment = "(\(self.queryFragment) = ARRAY["
        fragment.append(other.map { "\(bind: $0)" }.joined(separator: ", "))
        fragment.append("])")
        return SQLQueryExpression(fragment, as: Bool.self)
    }

    public func arrayEquals(_ other: some QueryExpression<QueryValue>) -> some QueryExpression<Bool>
    {
        SQLQueryExpression(
            "(\(self.queryFragment) = \(other.queryFragment))",
            as: Bool.self
        )
    }

    public func arrayNotEquals(_ other: [QueryValue.Element]) -> some QueryExpression<Bool> {
        var fragment: QueryFragment = "(\(self.queryFragment) <> ARRAY["
        fragment.append(other.map { "\(bind: $0)" }.joined(separator: ", "))
        fragment.append("])")
        return SQLQueryExpression(fragment, as: Bool.self)
    }
}

extension QueryExpression
where QueryValue: Swift.Collection, QueryValue.Element: QueryBindable & Comparable {

    public func arrayLessThan(_ other: [QueryValue.Element]) -> some QueryExpression<Bool> {
        var fragment: QueryFragment = "(\(self.queryFragment) < ARRAY["
        fragment.append(other.map { "\(bind: $0)" }.joined(separator: ", "))
        fragment.append("])")
        return SQLQueryExpression(fragment, as: Bool.self)
    }

    public func arrayGreaterThan(_ other: [QueryValue.Element]) -> some QueryExpression<Bool> {
        var fragment: QueryFragment = "(\(self.queryFragment) > ARRAY["
        fragment.append(other.map { "\(bind: $0)" }.joined(separator: ", "))
        fragment.append("])")
        return SQLQueryExpression(fragment, as: Bool.self)
    }
}
