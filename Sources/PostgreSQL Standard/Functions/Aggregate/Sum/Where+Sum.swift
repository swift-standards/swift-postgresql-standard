import Structured_Queries

extension Where {

    @inlinable
    public func sum<Value>(
        of expression: (From.TableColumns) -> some QueryExpression<Value>
    ) -> Select<Value._Optionalized.Wrapped?, From, ()>
    where
        Value: _OptionalPromotable,
        Value._Optionalized.Wrapped: Numeric,
        Value._Optionalized.Wrapped: QueryRepresentable
    {
        _aggregateSelect(of: expression) { $0._sum(distinct: false, filter: nil) }
    }

    @inlinable
    public func sum<Value, Filter: QueryExpression<Bool>>(
        of expression: (From.TableColumns) -> some QueryExpression<Value>,
        filter: @escaping (From.TableColumns) -> Filter
    ) -> Select<Value._Optionalized.Wrapped?, From, ()>
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
