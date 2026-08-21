import Structured_Queries_Primitives

extension Table {

    @inlinable
    public static func sum<Value>(
        of expression: (TableColumns) -> some QueryExpression<Value>
    ) -> Select<Value._Optionalized.Wrapped?, Self, ()>
    where
        Value: _OptionalPromotable,
        Value._Optionalized.Wrapped: Numeric,
        Value._Optionalized.Wrapped: QueryRepresentable
    {
        _aggregateSelect(of: expression) { $0._sum(distinct: false, filter: nil) }
    }

    @inlinable
    public static func sum<Value, Filter: QueryExpression<Bool>>(
        of expression: (TableColumns) -> some QueryExpression<Value>,
        filter: @escaping (TableColumns) -> Filter
    ) -> Select<Value._Optionalized.Wrapped?, Self, ()>
    where
        Value: _OptionalPromotable,
        Value._Optionalized.Wrapped: Numeric,
        Value._Optionalized.Wrapped: QueryRepresentable
    {
        _aggregateSelect(of: expression, filter: filter) {
            $0._sum(distinct: false, filter: $1.queryFragment)
        }
    }
}
