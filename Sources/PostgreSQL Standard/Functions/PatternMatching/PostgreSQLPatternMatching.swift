import Foundation
import Structured_Queries_Primitives

extension QueryExpression where QueryValue == String {

    public func ilike(
        _ pattern: some StringProtocol,
        escape: Character? = nil
    ) -> some QueryExpression<Bool> {
        IlikeOperator(string: self, pattern: "\(pattern)", escape: escape)
    }
}

private struct IlikeOperator<
    LHS: QueryExpression<String>,
    RHS: QueryExpression<String>
>: QueryExpression {
    typealias QueryValue = Bool

    let string: LHS
    let pattern: RHS
    let escape: Character?

    var queryFragment: QueryFragment {
        var query: QueryFragment = "(\(string.queryFragment) ILIKE \(pattern.queryFragment)"
        if let escape {
            query.append(" ESCAPE \(bind: String(escape))")
        }
        query.append(")")
        return query
    }
}
