import Foundation
import Structured_Queries_Primitives

public enum Conditional {}

public func Case<Base, QueryValue: _OptionalPromotable>(
    _ base: some QueryExpression<Base>
) -> Conditional.Case<Base, QueryValue> {
    Conditional.Case(base)
}

public func Case<QueryValue: _OptionalPromotable>() -> Conditional.Case<Bool, QueryValue> {
    Conditional.Case()
}
