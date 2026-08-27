import Structured_Queries

extension QueryExpression where QueryValue == Bool {

    public static func && (
        lhs: Self,
        rhs: some QueryExpression<QueryValue>
    ) -> some QueryExpression<QueryValue> {
        lhs.and(rhs)
    }

    public static func || (
        lhs: Self,
        rhs: some QueryExpression<QueryValue>
    ) -> some QueryExpression<QueryValue> {
        lhs.or(rhs)
    }

    public static prefix func ! (expression: Self) -> some QueryExpression<QueryValue> {
        expression.not()
    }

    public func and(_ other: some QueryExpression<QueryValue>) -> some QueryExpression<QueryValue> {
        BinaryOperator(lhs: self, operator: "AND", rhs: other)
    }

    public func or(_ other: some QueryExpression<QueryValue>) -> some QueryExpression<QueryValue> {
        BinaryOperator(lhs: self, operator: "OR", rhs: other)
    }

    public func not() -> some QueryExpression<QueryValue> {
        UnaryOperator(operator: "NOT", base: self)
    }
}

@_documentation(visibility: private)
public prefix func ! (
    expression: any QueryExpression<Bool>
) -> some QueryExpression<Bool> {
    func open(_ expression: some QueryExpression<Bool>) -> SQLQueryExpression<Bool> {
        SQLQueryExpression(expression.not())
    }
    return open(expression)
}

extension SQLQueryExpression<Bool> {
    public mutating func toggle() {
        self = Self(not())
    }
}
