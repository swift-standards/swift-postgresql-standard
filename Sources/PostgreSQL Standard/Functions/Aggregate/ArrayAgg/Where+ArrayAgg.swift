import Structured_Queries_Primitives

extension Where {

    @inlinable
    public func arrayAgg(
        of expression: (From.TableColumns) -> some QueryExpression
    ) -> Select<String?, From, ()> {
        _aggregateSelect(of: expression) { $0.arrayAgg() }
    }

    @inlinable
    public func arrayAgg<Expr: QueryExpression, Filter: QueryExpression<Bool>>(
        of expression: (From.TableColumns) -> Expr,
        filter: @escaping (From.TableColumns) -> Filter
    ) -> Select<String?, From, ()> {
        asSelect()
            .select { _ in
                expression(From.columns).arrayAgg(filter: filter(From.columns))
            }
    }
}
