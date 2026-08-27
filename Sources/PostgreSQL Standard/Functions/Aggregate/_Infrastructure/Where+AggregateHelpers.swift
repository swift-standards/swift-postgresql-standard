import Structured_Queries

extension Where {

    @usableFromInline
    internal func _aggregateSelect<Value, Result, Expr: QueryExpression<Value>>(
        of expression: (From.TableColumns) -> Expr,
        applying transform: (Expr) -> some QueryExpression<Result>
    ) -> Select<Result, From, ()> where Result: QueryRepresentable {
        let expr = expression(From.columns)
        return asSelect().select { _ in transform(expr) }
    }

    @usableFromInline
    internal func _aggregateSelect<
        Value,
        Result,
        Expr: QueryExpression<Value>,
        Filter: QueryExpression<Bool>
    >(
        of expression: (From.TableColumns) -> Expr,
        filter: @escaping (From.TableColumns) -> Filter,
        applying transform: (Expr, Filter) -> some QueryExpression<Result>
    ) -> Select<Result, From, ()> where Result: QueryRepresentable {
        asSelect()
            .select { _ in
                transform(expression(From.columns), filter(From.columns))
            }
    }
}
