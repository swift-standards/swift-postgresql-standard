import Structured_Queries

extension QueryExpression where QueryValue: QueryBindable & _OptionalPromotable {
    @usableFromInline
    internal func _max(
        filter: QueryFragment?
    ) -> AggregateFunction<QueryValue._Optionalized.Wrapped?> {
        AggregateFunction("max", [queryFragment], filter: filter)
    }

    public func max(
        filter: (some QueryExpression<Bool>)? = Bool?.none
    ) -> some QueryExpression<QueryValue._Optionalized.Wrapped?> {
        _max(filter: filter?.queryFragment)
    }
}
