import Foundation
import Structured_Queries_Primitives

extension TableColumn {

    public func jsonAgg(
        distinct isDistinct: Bool = false,
        order: (any QueryExpression)? = nil,
        filter: (some QueryExpression<Bool>)? = Bool?.none
    ) -> some QueryExpression<String?> {
        AggregateFunction<String?>(
            "json_agg",
            isDistinct: isDistinct,
            [queryFragment],
            order: order?.queryFragment,
            filter: filter?.queryFragment
        )
    }
}
