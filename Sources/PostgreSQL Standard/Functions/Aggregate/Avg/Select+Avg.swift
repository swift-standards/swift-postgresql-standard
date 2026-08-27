import Structured_Queries

extension Select {

    public func avg<Value>(
        of expression: (From.TableColumns) -> some QueryExpression<Value>
    ) -> Select<Double?, From, ()>
    where
        Columns == (),
        Joins == (),
        Value: _OptionalPromotable,
        Value._Optionalized.Wrapped: Numeric,
        Value._Optionalized.Wrapped: QueryRepresentable
    {
        let expr = expression(From.columns)
        return select { _ in expr._avg(distinct: false, filter: nil) }
    }

    public func avg<Value, each J: Table>(
        of expression: (From.TableColumns, repeat (each J).TableColumns) -> some QueryExpression<
            Value
        >
    ) -> Select<Double?, From, (repeat each J)>
    where
        Columns == (),
        Joins == (repeat each J),
        Value: _OptionalPromotable,
        Value._Optionalized.Wrapped: Numeric,
        Value._Optionalized.Wrapped: QueryRepresentable
    {
        let expr = expression(From.columns, repeat (each J).columns)
        return select { _ in expr._avg(distinct: false, filter: nil) }
    }

    public func avg<Value, each C: QueryRepresentable, each J: Table>(
        of expression: (From.TableColumns, repeat (each J).TableColumns) -> some QueryExpression<
            Value
        >
    ) -> Select<(repeat each C, Double?), From, (repeat each J)>
    where
        Columns == (repeat each C),
        Joins == (repeat each J),
        Value: _OptionalPromotable,
        Value._Optionalized.Wrapped: Numeric,
        Value._Optionalized.Wrapped: QueryRepresentable
    {
        let expr = expression(From.columns, repeat (each J).columns)
        return select { _ in expr._avg(distinct: false, filter: nil) }
    }

    public func avg<Value>(
        of expression: (From.TableColumns, Joins.TableColumns) -> some QueryExpression<Value>
    ) -> Select<Double?, From, Joins>
    where
        Columns == (),
        Joins: Table,
        Value: _OptionalPromotable,
        Value._Optionalized.Wrapped: Numeric,
        Value._Optionalized.Wrapped: QueryRepresentable
    {
        let expr = expression(From.columns, Joins.columns)
        return select { _, _ in expr._avg(distinct: false, filter: nil) }
    }

    public func avg<Value, each C: QueryRepresentable>(
        of expression: (From.TableColumns, Joins.TableColumns) -> some QueryExpression<Value>
    ) -> Select<(repeat each C, Double?), From, Joins>
    where
        Columns == (repeat each C),
        Joins: Table,
        Value: _OptionalPromotable,
        Value._Optionalized.Wrapped: Numeric,
        Value._Optionalized.Wrapped: QueryRepresentable
    {
        let expr = expression(From.columns, Joins.columns)
        return select { _, _ in expr._avg(distinct: false, filter: nil) }
    }
}
