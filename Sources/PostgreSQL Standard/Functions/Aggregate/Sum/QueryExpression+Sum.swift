import Structured_Queries_Primitives

extension QueryExpression
where QueryValue: _OptionalPromotable, QueryValue._Optionalized.Wrapped: Numeric {
    @usableFromInline
    internal func _sum(
        distinct isDistinct: Bool,
        filter: QueryFragment?
    ) -> AggregateFunction<QueryValue._Optionalized.Wrapped?> {
        AggregateFunction(
            "SUM",
            isDistinct: isDistinct,
            [queryFragment],
            filter: filter
        )
    }

    public func sum(
        distinct isDistinct: Bool = false,
        filter: (some QueryExpression<Bool>)? = Bool?.none
    ) -> some QueryExpression<QueryValue._Optionalized.Wrapped?> {
        _sum(distinct: isDistinct, filter: filter?.queryFragment)
    }
}
