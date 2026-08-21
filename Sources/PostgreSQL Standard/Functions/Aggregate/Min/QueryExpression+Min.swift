import Structured_Queries_Primitives

extension QueryExpression where QueryValue: QueryBindable & _OptionalPromotable {
    @usableFromInline
    internal func _min(
        filter: QueryFragment?
    ) -> AggregateFunction<QueryValue._Optionalized.Wrapped?> {
        AggregateFunction("min", [queryFragment], filter: filter)
    }

    public func min(
        filter: (some QueryExpression<Bool>)? = Bool?.none
    ) -> some QueryExpression<QueryValue._Optionalized.Wrapped?> {
        _min(filter: filter?.queryFragment)
    }
}
