import Structured_Queries_Primitives

extension Select {

    public func max<Value>(
        of expression: (From.TableColumns) -> some QueryExpression<Value>
    ) -> Select<Value._Optionalized.Wrapped?, From, ()>
    where
        Columns == (),
        Joins == (),
        Value: QueryBindable & _OptionalPromotable,
        Value._Optionalized.Wrapped: QueryRepresentable
    {
        let expr = expression(From.columns)
        return select { _ in expr._max(filter: nil) }
    }

    public func max<Value, each J: Table>(
        of expression: (From.TableColumns, repeat (each J).TableColumns) -> some QueryExpression<
            Value
        >
    ) -> Select<Value._Optionalized.Wrapped?, From, (repeat each J)>
    where
        Columns == (),
        Joins == (repeat each J),
        Value: QueryBindable & _OptionalPromotable,
        Value._Optionalized.Wrapped: QueryRepresentable
    {
        let expr = expression(From.columns, repeat (each J).columns)
        return select { _ in expr._max(filter: nil) }
    }

    public func max<Value, each C: QueryRepresentable, each J: Table>(
        of expression: (From.TableColumns, repeat (each J).TableColumns) -> some QueryExpression<
            Value
        >
    ) -> Select<(repeat each C, Value._Optionalized.Wrapped?), From, (repeat each J)>
    where
        Columns == (repeat each C),
        Joins == (repeat each J),
        Value: QueryBindable & _OptionalPromotable,
        Value._Optionalized.Wrapped: QueryRepresentable
    {
        let expr = expression(From.columns, repeat (each J).columns)
        return select { _ in expr._max(filter: nil) }
    }

    public func max<Value>(
        of expression: (From.TableColumns, Joins.TableColumns) -> some QueryExpression<Value>
    ) -> Select<Value._Optionalized.Wrapped?, From, Joins>
    where
        Columns == (),
        Joins: Table,
        Value: QueryBindable & _OptionalPromotable,
        Value._Optionalized.Wrapped: QueryRepresentable
    {
        let expr = expression(From.columns, Joins.columns)
        return select { _, _ in expr._max(filter: nil) }
    }

    public func max<Value, each C: QueryRepresentable>(
        of expression: (From.TableColumns, Joins.TableColumns) -> some QueryExpression<Value>
    ) -> Select<(repeat each C, Value._Optionalized.Wrapped?), From, Joins>
    where
        Columns == (repeat each C),
        Joins: Table,
        Value: QueryBindable & _OptionalPromotable,
        Value._Optionalized.Wrapped: QueryRepresentable
    {
        let expr = expression(From.columns, Joins.columns)
        return select { _, _ in expr._max(filter: nil) }
    }
}
