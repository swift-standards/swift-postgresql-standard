import Structured_Queries_Primitives

extension Select {

    public func sum<Value>(
        of expression: (From.TableColumns) -> some QueryExpression<Value>
    ) -> Select<Value._Optionalized.Wrapped?, From, ()>
    where
        Columns == (),
        Joins == (),
        Value: _OptionalPromotable,
        Value._Optionalized.Wrapped: Numeric,
        Value._Optionalized.Wrapped: QueryRepresentable
    {
        let expr = expression(From.columns)
        return select { _ in expr._sum(distinct: false, filter: nil) }
    }

    public func sum<Value, each J: Table>(
        of expression: (From.TableColumns, repeat (each J).TableColumns) -> some QueryExpression<
            Value
        >
    ) -> Select<Value._Optionalized.Wrapped?, From, (repeat each J)>
    where
        Columns == (),
        Joins == (repeat each J),
        Value: _OptionalPromotable,
        Value._Optionalized.Wrapped: Numeric,
        Value._Optionalized.Wrapped: QueryRepresentable
    {
        let expr = expression(From.columns, repeat (each J).columns)
        return select { _ in expr._sum(distinct: false, filter: nil) }
    }

    public func sum<Value, each C: QueryRepresentable, each J: Table>(
        of expression: (From.TableColumns, repeat (each J).TableColumns) -> some QueryExpression<
            Value
        >
    ) -> Select<(repeat each C, Value._Optionalized.Wrapped?), From, (repeat each J)>
    where
        Columns == (repeat each C),
        Joins == (repeat each J),
        Value: _OptionalPromotable,
        Value._Optionalized.Wrapped: Numeric,
        Value._Optionalized.Wrapped: QueryRepresentable
    {
        let expr = expression(From.columns, repeat (each J).columns)
        return select { _ in expr._sum(distinct: false, filter: nil) }
    }

    public func sum<Value>(
        of expression: (From.TableColumns, Joins.TableColumns) -> some QueryExpression<Value>
    ) -> Select<Value._Optionalized.Wrapped?, From, Joins>
    where
        Columns == (),
        Joins: Table,
        Value: _OptionalPromotable,
        Value._Optionalized.Wrapped: Numeric,
        Value._Optionalized.Wrapped: QueryRepresentable
    {
        let expr = expression(From.columns, Joins.columns)
        return select { _, _ in expr._sum(distinct: false, filter: nil) }
    }

    public func sum<Value, each C: QueryRepresentable>(
        of expression: (From.TableColumns, Joins.TableColumns) -> some QueryExpression<Value>
    ) -> Select<(repeat each C, Value._Optionalized.Wrapped?), From, Joins>
    where
        Columns == (repeat each C),
        Joins: Table,
        Value: _OptionalPromotable,
        Value._Optionalized.Wrapped: Numeric,
        Value._Optionalized.Wrapped: QueryRepresentable
    {
        let expr = expression(From.columns, Joins.columns)
        return select { _, _ in expr._sum(distinct: false, filter: nil) }
    }
}
