import Structured_Queries_Primitives

extension Where {

    @inlinable
    public func max<Value>(
        of expression: (From.TableColumns) -> some QueryExpression<Value>
    ) -> Select<Value._Optionalized.Wrapped?, From, ()>
    where
        Value: QueryBindable & _OptionalPromotable,
        Value._Optionalized.Wrapped: QueryRepresentable
    {
        _aggregateSelect(of: expression) { $0._max(filter: nil) }
    }

    @inlinable
    public func max<Value, Filter: QueryExpression<Bool>>(
        of expression: (From.TableColumns) -> some QueryExpression<Value>,
        filter: @escaping (From.TableColumns) -> Filter
    ) -> Select<Value._Optionalized.Wrapped?, From, ()>
    where
        Value: QueryBindable & _OptionalPromotable,
        Value._Optionalized.Wrapped: QueryRepresentable
    {
        _aggregateSelect(of: expression, filter: filter) { $0._max(filter: $1.queryFragment) }
    }
}
