import Structured_Queries_Primitives

extension QueryExpression where QueryValue: QueryExpression {
    func _in<S: Swift.Sequence>(_ expression: S) -> BinaryOperator<Bool>
    where S.Element: QueryExpression<QueryValue> {
        BinaryOperator(lhs: self, operator: "IN", rhs: S.Expression(elements: expression))
    }

    public func `in`<S: Swift.Sequence>(_ expression: S) -> some QueryExpression<Bool>
    where S.Element: QueryExpression<QueryValue> {
        _in(expression)
    }

    func _in(_ query: some Statement<QueryValue>) -> BinaryOperator<Bool> {
        BinaryOperator(
            lhs: self,
            operator: "IN",
            rhs: SQLQueryExpression("(\(query.query))", as: Void.self)
        )
    }

    public func `in`(_ query: some Statement<QueryValue>) -> some QueryExpression<Bool> {
        _in(query)
    }
}

extension Sequence where Element: QueryBindable {

    public func contains(
        _ element: some QueryExpression<Element.QueryValue>
    ) -> some QueryExpression<Bool> {
        element._in(self)
    }
}

extension Statement where QueryValue: QueryBindable {

    public func contains(
        _ element: some QueryExpression<QueryValue>
    ) -> some QueryExpression<Bool> {
        element._in(self)
    }
}

extension PartialSelectStatement {

    public func exists() -> some QueryExpression<Bool> {
        SQLQueryExpression("EXISTS \(self.queryFragment)")
    }
}

extension Table {

    public static func exists() -> some QueryExpression<Bool> {
        all.exists()
    }
}
