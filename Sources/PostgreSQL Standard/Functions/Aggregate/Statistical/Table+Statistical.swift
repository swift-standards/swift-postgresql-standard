import Structured_Queries

extension Table {

    @inlinable
    public static func stddev(
        of expression: (TableColumns) -> some QueryExpression<some Numeric>
    ) -> Select<Double?, Self, ()> {
        _aggregateSelect(of: expression) { $0._stddev(filter: nil) }
    }

    @inlinable
    public static func stddev<Filter: QueryExpression<Bool>>(
        of expression: (TableColumns) -> some QueryExpression<some Numeric>,
        filter: @escaping (TableColumns) -> Filter
    ) -> Select<Double?, Self, ()> {
        _aggregateSelect(of: expression, filter: filter) {
            $0._stddev(filter: $1.queryFragment)
        }
    }

    @inlinable
    public static func variance(
        of expression: (TableColumns) -> some QueryExpression<some Numeric>
    ) -> Select<Double?, Self, ()> {
        _aggregateSelect(of: expression) { $0._variance(filter: nil) }
    }

    @inlinable
    public static func variance<Filter: QueryExpression<Bool>>(
        of expression: (TableColumns) -> some QueryExpression<some Numeric>,
        filter: @escaping (TableColumns) -> Filter
    ) -> Select<Double?, Self, ()> {
        _aggregateSelect(of: expression, filter: filter) {
            $0._variance(filter: $1.queryFragment)
        }
    }
}
