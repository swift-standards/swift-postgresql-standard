import Foundation
import Structured_Queries_Primitives

extension QueryExpression {

    public func jsonbAgg(
        distinct isDistinct: Bool = false,
        order: (any QueryExpression)? = nil,
        filter: (some QueryExpression<Bool>)? = Bool?.none
    ) -> some QueryExpression<String?> {
        AggregateFunction<String?>(
            "JSONB_AGG",
            isDistinct: isDistinct,
            [queryFragment],
            order: order?.queryFragment,
            filter: filter?.queryFragment
        )
    }
}
