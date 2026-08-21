import Structured_Queries_Primitives

extension QueryExpression where QueryValue: QueryRepresentable {

    public static func == (
        lhs: Self,
        rhs: some QueryExpression<QueryValue>
    ) -> some QueryExpression<Bool> {
        lhs.eq(rhs)
    }

    public static func != (
        lhs: Self,
        rhs: some QueryExpression<QueryValue>
    ) -> some QueryExpression<Bool> {
        lhs.neq(rhs)
    }

    public func eq(_ other: some QueryExpression<QueryValue>) -> some QueryExpression<Bool> {
        BinaryOperator(lhs: self, operator: "=", rhs: other)
    }

    public func neq(_ other: some QueryExpression<QueryValue>) -> some QueryExpression<Bool> {
        BinaryOperator(lhs: self, operator: "<>", rhs: other)
    }

    public func `is`<Other: QueryRepresentable>(
        _ other: some QueryExpression<Other>
    ) -> some QueryExpression<Bool>
    where QueryValue._Optionalized.Wrapped == Other._Optionalized.Wrapped {
        BinaryOperator(lhs: self, operator: "IS", rhs: other)
    }

    public func isNot<Other: QueryRepresentable>(
        _ other: some QueryExpression<QueryValue._Optionalized>
    ) -> some QueryExpression<Bool>
    where QueryValue._Optionalized.Wrapped == Other._Optionalized.Wrapped {
        BinaryOperator(lhs: self, operator: "IS NOT", rhs: other)
    }
}

extension QueryExpression where QueryValue: QueryRepresentable & QueryExpression {
    @_documentation(visibility: private)
    public func `is`(
        _ other: _Null<QueryValue>
    ) -> some QueryExpression<Bool> {
        BinaryOperator(lhs: self, operator: "IS", rhs: other)
    }

    @_documentation(visibility: private)
    public func isNot(
        _ other: _Null<QueryValue>
    ) -> some QueryExpression<Bool> {
        BinaryOperator(lhs: self, operator: "IS NOT", rhs: other)
    }
}

extension QueryExpression where QueryValue: QueryRepresentable & _OptionalProtocol {
    @_documentation(visibility: private)
    public func eq(_ other: some QueryExpression<QueryValue.Wrapped>) -> some QueryExpression<Bool>
    {
        BinaryOperator(lhs: self, operator: "=", rhs: other)
    }

    @_documentation(visibility: private)
    public func neq(_ other: some QueryExpression<QueryValue.Wrapped>) -> some QueryExpression<Bool>
    {
        BinaryOperator(lhs: self, operator: "<>", rhs: other)
    }

    @_documentation(visibility: private)
    public func eq(_ other: some QueryExpression<QueryValue>) -> some QueryExpression<Bool> {
        BinaryOperator(lhs: self, operator: "=", rhs: other)
    }

    @_documentation(visibility: private)
    public func neq(_ other: some QueryExpression<QueryValue>) -> some QueryExpression<Bool> {
        BinaryOperator(lhs: self, operator: "<>", rhs: other)
    }

    @_documentation(visibility: private)
    public func `is`(
        _ other: some QueryExpression<QueryValue>
    ) -> some QueryExpression<Bool> {
        BinaryOperator(lhs: self, operator: "IS", rhs: other)
    }

    @_documentation(visibility: private)
    public func isNot(
        _ other: some QueryExpression<QueryValue>
    ) -> some QueryExpression<Bool> {
        BinaryOperator(lhs: self, operator: "IS NOT", rhs: other)
    }

    @_documentation(visibility: private)
    public func gt(_ other: some QueryExpression<QueryValue.Wrapped>) -> some QueryExpression<Bool>
    {
        BinaryOperator(lhs: self, operator: ">", rhs: other)
    }

    @_documentation(visibility: private)
    public func lt(_ other: some QueryExpression<QueryValue.Wrapped>) -> some QueryExpression<Bool>
    {
        BinaryOperator(lhs: self, operator: "<", rhs: other)
    }

    @_documentation(visibility: private)
    public func gte(_ other: some QueryExpression<QueryValue.Wrapped>) -> some QueryExpression<Bool>
    {
        BinaryOperator(lhs: self, operator: ">=", rhs: other)
    }

    @_documentation(visibility: private)
    public func lte(_ other: some QueryExpression<QueryValue.Wrapped>) -> some QueryExpression<Bool>
    {
        BinaryOperator(lhs: self, operator: "<=", rhs: other)
    }

    public static func > (
        lhs: Self,
        rhs: some QueryExpression<QueryValue.Wrapped>
    ) -> some QueryExpression<Bool> {
        lhs.gt(rhs)
    }

    public static func < (
        lhs: Self,
        rhs: some QueryExpression<QueryValue.Wrapped>
    ) -> some QueryExpression<Bool> {
        lhs.lt(rhs)
    }

    public static func >= (
        lhs: Self,
        rhs: some QueryExpression<QueryValue.Wrapped>
    ) -> some QueryExpression<Bool> {
        lhs.gte(rhs)
    }

    public static func <= (
        lhs: Self,
        rhs: some QueryExpression<QueryValue.Wrapped>
    ) -> some QueryExpression<Bool> {
        lhs.lte(rhs)
    }
}

@_disfavoredOverload
@_documentation(visibility: private)
public func == <QueryValue>(
    lhs: any QueryExpression<QueryValue>,
    rhs: some QueryExpression<QueryValue?>
) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: lhs, operator: isNull(rhs) ? "IS" : "=", rhs: rhs)
}

@_disfavoredOverload
@_documentation(visibility: private)
public func != <QueryValue>(
    lhs: any QueryExpression<QueryValue>,
    rhs: some QueryExpression<QueryValue?>
) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: lhs, operator: isNull(rhs) ? "IS NOT" : "<>", rhs: rhs)
}

@_documentation(visibility: private)
@_disfavoredOverload
public func == <QueryValue: _OptionalProtocol>(
    lhs: any QueryExpression<QueryValue>,
    rhs: some QueryExpression<QueryValue.Wrapped>
) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: lhs, operator: "=", rhs: rhs)
}

@_documentation(visibility: private)
@_disfavoredOverload
public func != <QueryValue: _OptionalProtocol>(
    lhs: any QueryExpression<QueryValue>,
    rhs: some QueryExpression<QueryValue.Wrapped>
) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: lhs, operator: "<>", rhs: rhs)
}

@_documentation(visibility: private)
public func == <QueryValue: _OptionalProtocol>(
    lhs: any QueryExpression<QueryValue>,
    rhs: some QueryExpression<QueryValue>
) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: lhs, operator: isNull(rhs) ? "IS" : "=", rhs: rhs)
}

@_documentation(visibility: private)
public func != <QueryValue: _OptionalProtocol>(
    lhs: any QueryExpression<QueryValue>,
    rhs: some QueryExpression<QueryValue>
) -> some QueryExpression<Bool> {
    BinaryOperator(lhs: lhs, operator: isNull(rhs) ? "IS NOT" : "<>", rhs: rhs)
}

@_documentation(visibility: private)
public func == <QueryValue: QueryBindable>(
    lhs: any QueryExpression<QueryValue>,
    rhs: _Null<QueryValue>
) -> some QueryExpression<Bool> {
    SQLQueryExpression(lhs).is(rhs)
}

@_documentation(visibility: private)
public func != <QueryValue: QueryBindable>(
    lhs: any QueryExpression<QueryValue>,
    rhs: _Null<QueryValue>
) -> some QueryExpression<Bool> {
    SQLQueryExpression(lhs).isNot(rhs)
}

@_documentation(visibility: private)
public func == <QueryValue: QueryBindable>(
    lhs: _Null<QueryValue>,
    rhs: any QueryExpression<QueryValue>
) -> some QueryExpression<Bool> {
    SQLQueryExpression(rhs).is(lhs)
}

@_documentation(visibility: private)
public func != <QueryValue: QueryBindable>(
    lhs: _Null<QueryValue>,
    rhs: any QueryExpression<QueryValue>
) -> some QueryExpression<Bool> {
    SQLQueryExpression(rhs).isNot(lhs)
}

extension QueryExpression where QueryValue: _OptionalPromotable {

    public static func < (
        lhs: Self,
        rhs: some QueryExpression<QueryValue>
    ) -> some QueryExpression<Bool> {
        lhs.lt(rhs)
    }

    public static func > (
        lhs: Self,
        rhs: some QueryExpression<QueryValue>
    ) -> some QueryExpression<Bool> {
        lhs.gt(rhs)
    }

    public static func <= (
        lhs: Self,
        rhs: some QueryExpression<QueryValue>
    ) -> some QueryExpression<Bool> {
        lhs.lte(rhs)
    }

    public static func >= (
        lhs: Self,
        rhs: some QueryExpression<QueryValue>
    ) -> some QueryExpression<Bool> {
        lhs.gte(rhs)
    }

    public func lt(
        _ other: some QueryExpression<QueryValue>
    ) -> some QueryExpression<Bool> {
        BinaryOperator(lhs: self, operator: "<", rhs: other)
    }

    public func gt(
        _ other: some QueryExpression<QueryValue>
    ) -> some QueryExpression<Bool> {
        BinaryOperator(lhs: self, operator: ">", rhs: other)
    }

    public func lte(
        _ other: some QueryExpression<QueryValue>
    ) -> some QueryExpression<Bool> {
        BinaryOperator(lhs: self, operator: "<=", rhs: other)
    }

    public func gte(
        _ other: some QueryExpression<QueryValue>
    ) -> some QueryExpression<Bool> {
        BinaryOperator(lhs: self, operator: ">=", rhs: other)
    }
}

extension QueryExpression where QueryValue: QueryExpression {

    public func between(
        _ lowerBound: some QueryExpression<QueryValue>,
        and upperBound: some QueryExpression<QueryValue>
    ) -> some QueryExpression<Bool> {
        SQLQueryExpression("\(self) BETWEEN \(lowerBound) AND \(upperBound)")
    }
}

extension ClosedRange where Bound: QueryBindable {

    public func contains(
        _ element: some QueryExpression<Bound.QueryValue>
    ) -> some QueryExpression<Bool> {
        element.between(lowerBound, and: upperBound)
    }
}
