import Structured_Queries

extension ColumnGroup {

    public func eq(_ other: Values) -> some QueryExpression<Bool> {
        SQLQueryExpression<Bool>(
            "(\(queryFragment)) = (\(Values(queryOutput: other).queryFragment))"
        )
    }
}
