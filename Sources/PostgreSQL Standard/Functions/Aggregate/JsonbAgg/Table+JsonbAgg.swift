import Structured_Queries

extension Table {

    @inlinable
    public static func jsonbAgg(
        of expression: (TableColumns) -> some QueryExpression
    ) -> Select<String?, Self, ()> {
        _aggregateSelect(of: expression) { $0.jsonbAgg() }
    }

    @inlinable
    public static func jsonbAgg<Expr: QueryExpression, Filter: QueryExpression<Bool>>(
        of expression: (TableColumns) -> Expr,
        filter: @escaping (TableColumns) -> Filter
    ) -> Select<String?, Self, ()> {
        Self.all
            .asSelect()
            .select { _ in
                expression(columns).jsonbAgg(filter: filter(columns))
            }
    }
}
