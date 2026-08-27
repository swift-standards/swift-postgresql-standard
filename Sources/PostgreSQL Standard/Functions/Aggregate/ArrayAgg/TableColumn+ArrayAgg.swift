import Foundation
import Structured_Queries

extension TableColumn {

    public func arrayAgg(
        distinct isDistinct: Bool = false,
        order: (any QueryExpression)? = nil,
        filter: (some QueryExpression<Bool>)? = Bool?.none
    ) -> some QueryExpression<String?> {
        AggregateFunction<String?>(
            "array_agg",
            isDistinct: isDistinct,
            [queryFragment],
            order: order?.queryFragment,
            filter: filter?.queryFragment
        )
    }
}
