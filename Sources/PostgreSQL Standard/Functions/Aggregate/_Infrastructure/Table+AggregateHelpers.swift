import Structured_Queries

extension Table {

    @usableFromInline
    internal static func _aggregateSelect<Value, Result, Expr: QueryExpression<Value>>(
        of expression: (TableColumns) -> Expr,
        applying transform: (Expr) -> some QueryExpression<Result>
    ) -> Select<Result, Self, ()> where Result: QueryRepresentable {
        Self.all
            .asSelect()
            .select { _ in
                transform(expression(columns))
            }
    }

    @usableFromInline
    internal static func _aggregateSelect<
        Value,
        Result,
        Expr: QueryExpression<Value>,
        Filter: QueryExpression<Bool>
    >(
        of expression: (TableColumns) -> Expr,
        filter: @escaping (TableColumns) -> Filter,
        applying transform: (Expr, Filter) -> some QueryExpression<Result>
    ) -> Select<Result, Self, ()> where Result: QueryRepresentable {
        Self.all
            .asSelect()
            .select { _ in
                transform(expression(columns), filter(columns))
            }
    }
}
