import Structured_Queries

extension Table {

    @inlinable
    public static func avg<Value>(
        of expression: (TableColumns) -> some QueryExpression<Value>
    ) -> Select<Double?, Self, ()>
    where Value: _OptionalPromotable, Value._Optionalized.Wrapped: Numeric {
        _aggregateSelect(of: expression) { $0._avg(distinct: false, filter: nil) }
    }

    @inlinable
    public static func avg<Value, Filter: QueryExpression<Bool>>(
        of expression: (TableColumns) -> some QueryExpression<Value>,
        filter: @escaping (TableColumns) -> Filter
    ) -> Select<Double?, Self, ()>
    where Value: _OptionalPromotable, Value._Optionalized.Wrapped: Numeric {
        _aggregateSelect(of: expression, filter: filter) {
            $0._avg(distinct: false, filter: $1.queryFragment)
        }
    }
}
