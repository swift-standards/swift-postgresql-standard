import Structured_Queries_Primitives

extension Where {

    @inlinable
    public func avg<Value>(
        of expression: (From.TableColumns) -> some QueryExpression<Value>
    ) -> Select<Double?, From, ()>
    where Value: _OptionalPromotable, Value._Optionalized.Wrapped: Numeric {
        _aggregateSelect(of: expression) { $0._avg(distinct: false, filter: nil) }
    }

    @inlinable
    public func avg<Value, Filter: QueryExpression<Bool>>(
        of expression: (From.TableColumns) -> some QueryExpression<Value>,
        filter: @escaping (From.TableColumns) -> Filter
    ) -> Select<Double?, From, ()>
    where Value: _OptionalPromotable, Value._Optionalized.Wrapped: Numeric {
        _aggregateSelect(of: expression, filter: filter) {
            $0._avg(distinct: false, filter: $1.queryFragment)
        }
    }
}
