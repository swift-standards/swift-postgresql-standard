import Foundation
import Structured_Queries

extension QueryExpression where QueryValue == String {

    public func stringAgg(
        _ separator: String = ",",
        order: (any QueryExpression)? = nil,
        filter: (some QueryExpression<Bool>)? = Bool?.none
    ) -> some QueryExpression<String?> {
        AggregateFunction<String?>(
            "STRING_AGG",
            [queryFragment, "\(bind: separator)"],
            order: order?.queryFragment,
            filter: filter?.queryFragment
        )
    }

    public func stringAgg(
        distinct isDistinct: Bool,
        separator: String = ",",
        order: (any QueryExpression)? = nil,
        filter: (some QueryExpression<Bool>)? = Bool?.none
    ) -> some QueryExpression<String?> {
        AggregateFunction<String?>(
            "STRING_AGG",
            isDistinct: isDistinct,
            [queryFragment, "\(bind: separator)"],
            order: order?.queryFragment,
            filter: filter?.queryFragment
        )
    }
}

extension QueryExpression {

    public func stringAgg(
        _ separator: String = ",",
        order: (any QueryExpression)? = nil,
        filter: (some QueryExpression<Bool>)? = Bool?.none
    ) -> some QueryExpression<String?> {
        AggregateFunction<String?>(
            "STRING_AGG",
            ["CAST(\(queryFragment) AS TEXT)", "\(bind: separator)"],
            order: order?.queryFragment,
            filter: filter?.queryFragment
        )
    }
}

extension TableColumn {

    @available(
        *,
        deprecated,
        message:
            "Use QueryExpression.stringAgg(_:order:filter:) instead for DISTINCT, ORDER BY, and FILTER support"
    )
    public func stringAgg(_ separator: String) -> some QueryExpression<String?> {
        AggregateFunction<String?>(
            "string_agg",
            [queryFragment, "\(bind: separator)"]
        )
    }
}
