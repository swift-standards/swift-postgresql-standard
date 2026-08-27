import Structured_Queries

extension Where {

    @inlinable
    public func min<Value>(
        of expression: (From.TableColumns) -> some QueryExpression<Value>
    ) -> Select<Value._Optionalized.Wrapped?, From, ()>
    where
        Value: QueryBindable & _OptionalPromotable,
        Value._Optionalized.Wrapped: QueryRepresentable
    {
        _aggregateSelect(of: expression) { $0._min(filter: nil) }
    }

    @inlinable
    public func min<Value, Filter: QueryExpression<Bool>>(
        of expression: (From.TableColumns) -> some QueryExpression<Value>,
        filter: @escaping (From.TableColumns) -> Filter
    ) -> Select<Value._Optionalized.Wrapped?, From, ()>
    where
        Value: QueryBindable & _OptionalPromotable,
        Value._Optionalized.Wrapped: QueryRepresentable
    {
        _aggregateSelect(of: expression, filter: filter) { $0._min(filter: $1.queryFragment) }
    }
}
