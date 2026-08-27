import Foundation
import Structured_Queries

extension QueryExpression where QueryValue: Numeric {
    @usableFromInline
    internal func _stddev(filter: QueryFragment?) -> AggregateFunction<Double?> {
        AggregateFunction(
            "STDDEV",
            [queryFragment],
            filter: filter
        )
    }

    @usableFromInline
    internal func _variance(filter: QueryFragment?) -> AggregateFunction<Double?> {
        AggregateFunction(
            "VARIANCE",
            [queryFragment],
            filter: filter
        )
    }

    public func stddev(
        filter: (some QueryExpression<Bool>)? = Bool?.none
    ) -> some QueryExpression<Double?> {
        _stddev(filter: filter?.queryFragment)
    }

    public func stddevPop(
        filter: (some QueryExpression<Bool>)? = Bool?.none
    ) -> some QueryExpression<Double?> {
        AggregateFunction<Double?>(
            "STDDEV_POP",
            [queryFragment],
            filter: filter?.queryFragment
        )
    }

    public func stddevSamp(
        filter: (some QueryExpression<Bool>)? = Bool?.none
    ) -> some QueryExpression<Double?> {
        AggregateFunction<Double?>(
            "STDDEV_SAMP",
            [queryFragment],
            filter: filter?.queryFragment
        )
    }

    public func variance(
        filter: (some QueryExpression<Bool>)? = Bool?.none
    ) -> some QueryExpression<Double?> {
        _variance(filter: filter?.queryFragment)
    }

    public func varPop(
        filter: (some QueryExpression<Bool>)? = Bool?.none
    ) -> some QueryExpression<Double?> {
        AggregateFunction<Double?>(
            "VAR_POP",
            [queryFragment],
            filter: filter?.queryFragment
        )
    }

    public func varSamp(
        filter: (some QueryExpression<Bool>)? = Bool?.none
    ) -> some QueryExpression<Double?> {
        AggregateFunction<Double?>(
            "VAR_SAMP",
            [queryFragment],
            filter: filter?.queryFragment
        )
    }
}
