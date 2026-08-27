import Foundation
import Structured_Queries

public func greatest<Value: Comparable & QueryBindable>(
    _ v1: some QueryExpression<Value>,
    _ v2: some QueryExpression<Value>
) -> some QueryExpression<Value?> {
    SQLQueryExpression(
        "GREATEST(\(v1.queryFragment), \(v2.queryFragment))",
        as: Value?.self
    )
}

public func greatest<Value: Comparable & QueryBindable>(
    _ v1: some QueryExpression<Value>,
    _ v2: some QueryExpression<Value>,
    _ v3: some QueryExpression<Value>
) -> some QueryExpression<Value?> {
    SQLQueryExpression(
        "GREATEST(\(v1.queryFragment), \(v2.queryFragment), \(v3.queryFragment))",
        as: Value?.self
    )
}

public func greatest<Value: Comparable & QueryBindable>(
    _ v1: some QueryExpression<Value>,
    _ v2: some QueryExpression<Value>,
    _ v3: some QueryExpression<Value>,
    _ v4: some QueryExpression<Value>
) -> some QueryExpression<Value?> {
    SQLQueryExpression(
        "GREATEST(\(v1.queryFragment), \(v2.queryFragment), \(v3.queryFragment), \(v4.queryFragment))",
        as: Value?.self
    )
}

public func greatest<Value: Comparable & QueryBindable>(
    _ values: Value...
) -> some QueryExpression<Value?> {
    let fragments = values.map { "\(bind: $0)" }.joined(separator: ", ")
    return SQLQueryExpression(
        "GREATEST(\(fragments))",
        as: Value?.self
    )
}

public func least<Value: Comparable & QueryBindable>(
    _ v1: some QueryExpression<Value>,
    _ v2: some QueryExpression<Value>
) -> some QueryExpression<Value?> {
    SQLQueryExpression(
        "LEAST(\(v1.queryFragment), \(v2.queryFragment))",
        as: Value?.self
    )
}

public func least<Value: Comparable & QueryBindable>(
    _ v1: some QueryExpression<Value>,
    _ v2: some QueryExpression<Value>,
    _ v3: some QueryExpression<Value>
) -> some QueryExpression<Value?> {
    SQLQueryExpression(
        "LEAST(\(v1.queryFragment), \(v2.queryFragment), \(v3.queryFragment))",
        as: Value?.self
    )
}

public func least<Value: Comparable & QueryBindable>(
    _ v1: some QueryExpression<Value>,
    _ v2: some QueryExpression<Value>,
    _ v3: some QueryExpression<Value>,
    _ v4: some QueryExpression<Value>
) -> some QueryExpression<Value?> {
    SQLQueryExpression(
        "LEAST(\(v1.queryFragment), \(v2.queryFragment), \(v3.queryFragment), \(v4.queryFragment))",
        as: Value?.self
    )
}

public func least<Value: Comparable & QueryBindable>(
    _ values: Value...
) -> some QueryExpression<Value?> {
    let fragments = values.map { "\(bind: $0)" }.joined(separator: ", ")
    return SQLQueryExpression(
        "LEAST(\(fragments))",
        as: Value?.self
    )
}

public func numNonNulls<Value: QueryBindable>(
    _ v1: some QueryExpression<Value?>,
    _ v2: some QueryExpression<Value?>
) -> some QueryExpression<Int> {
    SQLQueryExpression(
        "num_nonnulls(\(v1.queryFragment), \(v2.queryFragment))",
        as: Int.self
    )
}

public func numNonNulls<Value: QueryBindable>(
    _ v1: some QueryExpression<Value?>,
    _ v2: some QueryExpression<Value?>,
    _ v3: some QueryExpression<Value?>
) -> some QueryExpression<Int> {
    SQLQueryExpression(
        "num_nonnulls(\(v1.queryFragment), \(v2.queryFragment), \(v3.queryFragment))",
        as: Int.self
    )
}

public func numNonNulls<Value: QueryBindable>(
    _ v1: some QueryExpression<Value?>,
    _ v2: some QueryExpression<Value?>,
    _ v3: some QueryExpression<Value?>,
    _ v4: some QueryExpression<Value?>
) -> some QueryExpression<Int> {
    SQLQueryExpression(
        "num_nonnulls(\(v1.queryFragment), \(v2.queryFragment), \(v3.queryFragment), \(v4.queryFragment))",
        as: Int.self
    )
}

public func numNulls<Value: QueryBindable>(
    _ v1: some QueryExpression<Value?>,
    _ v2: some QueryExpression<Value?>
) -> some QueryExpression<Int> {
    SQLQueryExpression(
        "num_nulls(\(v1.queryFragment), \(v2.queryFragment))",
        as: Int.self
    )
}

public func numNulls<Value: QueryBindable>(
    _ v1: some QueryExpression<Value?>,
    _ v2: some QueryExpression<Value?>,
    _ v3: some QueryExpression<Value?>
) -> some QueryExpression<Int> {
    SQLQueryExpression(
        "num_nulls(\(v1.queryFragment), \(v2.queryFragment), \(v3.queryFragment))",
        as: Int.self
    )
}

public func numNulls<Value: QueryBindable>(
    _ v1: some QueryExpression<Value?>,
    _ v2: some QueryExpression<Value?>,
    _ v3: some QueryExpression<Value?>,
    _ v4: some QueryExpression<Value?>
) -> some QueryExpression<Int> {
    SQLQueryExpression(
        "num_nulls(\(v1.queryFragment), \(v2.queryFragment), \(v3.queryFragment), \(v4.queryFragment))",
        as: Int.self
    )
}

extension QueryExpression where QueryValue: Equatable & QueryBindable {

    public func isDistinctFrom(_ other: QueryValue) -> some QueryExpression<Bool> {
        SQLQueryExpression(
            "(\(self.queryFragment) IS DISTINCT FROM \(bind: other))",
            as: Bool.self
        )
    }

    public func isDistinctFrom(
        _ other: some QueryExpression<QueryValue>
    ) -> some QueryExpression<
        Bool
    > {
        SQLQueryExpression(
            "(\(self.queryFragment) IS DISTINCT FROM \(other.queryFragment))",
            as: Bool.self
        )
    }

    public func isNotDistinctFrom(_ other: QueryValue) -> some QueryExpression<Bool> {
        SQLQueryExpression(
            "(\(self.queryFragment) IS NOT DISTINCT FROM \(bind: other))",
            as: Bool.self
        )
    }

    public func isNotDistinctFrom(
        _ other: some QueryExpression<QueryValue>
    )
        -> some QueryExpression<Bool>
    {
        SQLQueryExpression(
            "(\(self.queryFragment) IS NOT DISTINCT FROM \(other.queryFragment))",
            as: Bool.self
        )
    }
}

public func nullif<Value: Equatable & QueryBindable>(
    _ value1: some QueryExpression<Value>,
    _ value2: some QueryExpression<Value>
) -> some QueryExpression<Value?> {
    SQLQueryExpression(
        "NULLIF(\(value1.queryFragment), \(value2.queryFragment))",
        as: Value?.self
    )
}

public func nullif<Value: Equatable & QueryBindable>(
    _ value: some QueryExpression<Value>,
    _ compareTo: Value
) -> some QueryExpression<Value?> {
    SQLQueryExpression(
        "NULLIF(\(value.queryFragment), \(bind: compareTo))",
        as: Value?.self
    )
}

extension QueryExpression where QueryValue: Equatable & QueryBindable {

    public func nullif(_ other: QueryValue) -> some QueryExpression<QueryValue?> {
        SQLQueryExpression(
            "NULLIF(\(self.queryFragment), \(bind: other))",
            as: QueryValue?.self
        )
    }

    public func nullif(
        _ other: some QueryExpression<QueryValue>
    ) -> some QueryExpression<
        QueryValue?
    > {
        SQLQueryExpression(
            "NULLIF(\(self.queryFragment), \(other.queryFragment))",
            as: QueryValue?.self
        )
    }
}
