import Structured_Queries_Primitives

extension Table {

    @inlinable
    public static func min<Value>(
        of expression: (TableColumns) -> some QueryExpression<Value>
    ) -> Select<Value._Optionalized.Wrapped?, Self, ()>
    where
        Value: QueryBindable & _OptionalPromotable,
        Value._Optionalized.Wrapped: QueryRepresentable
    {
        _aggregateSelect(of: expression) { $0._min(filter: nil) }
    }

    @inlinable
    public static func min<Value, Filter: QueryExpression<Bool>>(
        of expression: (TableColumns) -> some QueryExpression<Value>,
        filter: @escaping (TableColumns) -> Filter
    ) -> Select<Value._Optionalized.Wrapped?, Self, ()>
    where
        Value: QueryBindable & _OptionalPromotable,
        Value._Optionalized.Wrapped: QueryRepresentable
    {
        _aggregateSelect(of: expression, filter: filter) { $0._min(filter: $1.queryFragment) }
    }
}
