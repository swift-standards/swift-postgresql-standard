import Structured_Queries

extension Where {

    @inlinable
    public func stddev(
        of expression: (From.TableColumns) -> some QueryExpression<some Numeric>
    ) -> Select<Double?, From, ()> {
        _aggregateSelect(of: expression) { $0._stddev(filter: nil) }
    }

    @inlinable
    public func stddev<Filter: QueryExpression<Bool>>(
        of expression: (From.TableColumns) -> some QueryExpression<some Numeric>,
        filter: @escaping (From.TableColumns) -> Filter
    ) -> Select<Double?, From, ()> {
        _aggregateSelect(of: expression, filter: filter) {
            $0._stddev(filter: $1.queryFragment)
        }
    }

    @inlinable
    public func variance(
        of expression: (From.TableColumns) -> some QueryExpression<some Numeric>
    ) -> Select<Double?, From, ()> {
        _aggregateSelect(of: expression) { $0._variance(filter: nil) }
    }

    @inlinable
    public func variance<Filter: QueryExpression<Bool>>(
        of expression: (From.TableColumns) -> some QueryExpression<some Numeric>,
        filter: @escaping (From.TableColumns) -> Filter
    ) -> Select<Double?, From, ()> {
        _aggregateSelect(of: expression, filter: filter) {
            $0._variance(filter: $1.queryFragment)
        }
    }
}
