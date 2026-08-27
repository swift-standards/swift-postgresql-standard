import Structured_Queries

extension Table {

    @inlinable
    public static func arrayAgg(
        of expression: (TableColumns) -> some QueryExpression
    ) -> Select<String?, Self, ()> {
        _aggregateSelect(of: expression) { $0.arrayAgg() }
    }

    @inlinable
    public static func arrayAgg<Expr: QueryExpression, Filter: QueryExpression<Bool>>(
        of expression: (TableColumns) -> Expr,
        filter: @escaping (TableColumns) -> Filter
    ) -> Select<String?, Self, ()> {
        Self.all
            .asSelect()
            .select { _ in
                expression(columns).arrayAgg(filter: filter(columns))
            }
    }
}
