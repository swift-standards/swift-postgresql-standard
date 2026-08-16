import Structured_Queries_Primitives

extension QueryExpression
where QueryValue: _OptionalPromotable, QueryValue._Optionalized.Wrapped: Numeric {
    @usableFromInline
    internal func _avg(
        distinct isDistinct: Bool,
        filter: QueryFragment?
    ) -> AggregateFunction<Double?> {
        AggregateFunction(
            "avg",
            isDistinct: isDistinct,
            [queryFragment],
            filter: filter
        )
    }

    /// An average aggregate of this expression.
    ///
    /// ```swift
    /// Item.select { $0.price.avg() }
    /// // SELECT avg("items"."price") FROM "items"
    /// ```
    ///
    /// - Parameters:
    ///   - isDistinct: Whether or not to include a `DISTINCT` clause, which filters duplicates from
    ///     the aggregation.
    ///   - filter: A `FILTER` clause to apply to the aggregation.
    /// - Returns: An average aggregate of this expression.
    public func avg(
        distinct isDistinct: Bool = false,
        filter: (some QueryExpression<Bool>)? = Bool?.none
    ) -> some QueryExpression<Double?> {
        _avg(distinct: isDistinct, filter: filter?.queryFragment)
    }
}
