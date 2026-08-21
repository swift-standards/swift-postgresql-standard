import Structured_Queries_Primitives

extension QueryExpression where QueryValue: Numeric {

    public static func + (
        lhs: Self,
        rhs: some QueryExpression<QueryValue>
    ) -> some QueryExpression<QueryValue> {
        BinaryOperator(lhs: lhs, operator: "+", rhs: rhs)
    }

    public static func - (
        lhs: Self,
        rhs: some QueryExpression<QueryValue>
    ) -> some QueryExpression<QueryValue> {
        BinaryOperator(lhs: lhs, operator: "-", rhs: rhs)
    }

    public static func * (
        lhs: Self,
        rhs: some QueryExpression<QueryValue>
    ) -> some QueryExpression<QueryValue> {
        BinaryOperator(lhs: lhs, operator: "*", rhs: rhs)
    }

    public static func / (
        lhs: Self,
        rhs: some QueryExpression<QueryValue>
    ) -> some QueryExpression<QueryValue> {
        BinaryOperator(lhs: lhs, operator: "/", rhs: rhs)
    }

    public static prefix func - (expression: Self) -> some QueryExpression<QueryValue> {
        UnaryOperator(operator: "-", base: expression, separator: "")
    }

    public static prefix func + (expression: Self) -> some QueryExpression<QueryValue> {
        UnaryOperator(operator: "+", base: expression, separator: "")
    }
}

@_documentation(visibility: private)
public prefix func - <QueryValue: Numeric>(
    expression: some QueryExpression<QueryValue>
) -> some QueryExpression<QueryValue> {
    SQLQueryExpression(UnaryOperator(operator: "-", base: expression, separator: ""))
}

@_documentation(visibility: private)
public prefix func + <QueryValue: Numeric>(
    expression: some QueryExpression<QueryValue>
) -> some QueryExpression<QueryValue> {
    SQLQueryExpression(UnaryOperator(operator: "+", base: expression, separator: ""))
}

extension SQLQueryExpression where QueryValue: Numeric {

    public static func += (lhs: inout Self, rhs: some QueryExpression<QueryValue>) {
        lhs = Self(lhs + rhs)
    }

    public static func -= (lhs: inout Self, rhs: some QueryExpression<QueryValue>) {
        lhs = Self(lhs - rhs)
    }

    public static func *= (lhs: inout Self, rhs: some QueryExpression<QueryValue>) {
        lhs = Self(lhs * rhs)
    }

    public static func /= (lhs: inout Self, rhs: some QueryExpression<QueryValue>) {
        lhs = Self(lhs / rhs)
    }

    public mutating func negate() {
        self = Self(-self)
    }
}

extension QueryExpression where QueryValue: BinaryInteger {

    public static func % (
        lhs: Self,
        rhs: some QueryExpression<QueryValue>
    ) -> some QueryExpression<QueryValue?> {
        BinaryOperator(lhs: lhs, operator: "%", rhs: rhs)
    }

    public static func & (
        lhs: Self,
        rhs: some QueryExpression<QueryValue>
    ) -> some QueryExpression<QueryValue> {
        BinaryOperator(lhs: lhs, operator: "&", rhs: rhs)
    }

    public static func | (
        lhs: Self,
        rhs: some QueryExpression<QueryValue>
    ) -> some QueryExpression<QueryValue> {
        BinaryOperator(lhs: lhs, operator: "|", rhs: rhs)
    }

    public static func << (
        lhs: Self,
        rhs: some QueryExpression<QueryValue>
    ) -> some QueryExpression<QueryValue> {
        BinaryOperator(lhs: lhs, operator: "<<", rhs: rhs)
    }

    public static func >> (
        lhs: Self,
        rhs: some QueryExpression<QueryValue>
    ) -> some QueryExpression<QueryValue> {
        BinaryOperator(lhs: lhs, operator: ">>", rhs: rhs)
    }

    public static prefix func ~ (expression: Self) -> some QueryExpression<QueryValue> {
        UnaryOperator(operator: "~", base: expression, separator: "")
    }
}

@_documentation(visibility: private)
public prefix func ~ <QueryValue: BinaryInteger>(
    expression: some QueryExpression<QueryValue>
) -> some QueryExpression<QueryValue> {
    SQLQueryExpression(UnaryOperator(operator: "~", base: expression, separator: ""))
}

extension SQLQueryExpression where QueryValue: BinaryInteger {
    public static func &= (lhs: inout Self, rhs: some QueryExpression<QueryValue>) {
        lhs = Self(lhs & rhs)
    }

    public static func |= (lhs: inout Self, rhs: some QueryExpression<QueryValue>) {
        lhs = Self(lhs | rhs)
    }

    public static func <<= (lhs: inout Self, rhs: some QueryExpression<QueryValue>) {
        lhs = Self(lhs << rhs)
    }

    public static func >>= (lhs: inout Self, rhs: some QueryExpression<QueryValue>) {
        lhs = Self(lhs >> rhs)
    }
}
