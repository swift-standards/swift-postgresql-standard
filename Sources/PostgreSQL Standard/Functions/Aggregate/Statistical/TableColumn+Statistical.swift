import Foundation
import Structured_Queries_Primitives

extension TableColumn where Value: Numeric {

    public func stddev(
        filter: (some QueryExpression<Bool>)? = Bool?.none
    ) -> some QueryExpression<Double> {
        AggregateFunction<Double>(
            "stddev",
            [queryFragment],
            filter: filter?.queryFragment
        )
    }

    public func stddevPop(
        filter: (some QueryExpression<Bool>)? = Bool?.none
    ) -> some QueryExpression<Double> {
        AggregateFunction<Double>(
            "stddev_pop",
            [queryFragment],
            filter: filter?.queryFragment
        )
    }

    public func stddevSamp(
        filter: (some QueryExpression<Bool>)? = Bool?.none
    ) -> some QueryExpression<Double> {
        AggregateFunction<Double>(
            "stddev_samp",
            [queryFragment],
            filter: filter?.queryFragment
        )
    }

    public func variance(
        filter: (some QueryExpression<Bool>)? = Bool?.none
    ) -> some QueryExpression<Double> {
        AggregateFunction<Double>(
            "variance",
            [queryFragment],
            filter: filter?.queryFragment
        )
    }
}
