import Structured_Queries

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

    public func avg(
        distinct isDistinct: Bool = false,
        filter: (some QueryExpression<Bool>)? = Bool?.none
    ) -> some QueryExpression<Double?> {
        _avg(distinct: isDistinct, filter: filter?.queryFragment)
    }
}
