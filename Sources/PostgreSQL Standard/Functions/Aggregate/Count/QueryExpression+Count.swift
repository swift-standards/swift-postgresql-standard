import Structured_Queries_Primitives

extension QueryExpression where QueryValue: QueryBindable {

    public func count(
        distinct isDistinct: Bool = false,
        filter: (some QueryExpression<Bool>)? = Bool?.none
    ) -> some QueryExpression<Int> {
        AggregateFunction(
            "count",
            isDistinct: isDistinct,
            [queryFragment],
            filter: filter?.queryFragment
        )
    }
}

extension QueryExpression where Self == AggregateFunction<Int> {

    public static func count(
        filter: (any QueryExpression<Bool>)? = nil
    ) -> Self {
        AggregateFunction("count", ["*"], filter: filter?.queryFragment)
    }
}
