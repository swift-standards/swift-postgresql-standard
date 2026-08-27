import Structured_Queries

internal func isNull<Value>(_ expression: some QueryExpression<Value>) -> Bool {
    (expression as? any _OptionalProtocol).map { $0._wrapped == nil } ?? false
}

public struct _Null<Wrapped: QueryExpression>: QueryExpression {
    public typealias QueryValue = Wrapped?
    public var queryFragment: QueryFragment {
        Wrapped?.none.queryFragment
    }
}

extension _Null: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {}
}

struct UnaryOperator<QueryValue>: QueryExpression {
    let `operator`: QueryFragment
    let base: QueryFragment
    let separator: QueryFragment

    init(operator: QueryFragment, base: some QueryExpression, separator: QueryFragment = " ") {
        self.operator = `operator`
        self.base = base.queryFragment
        self.separator = separator
    }

    var queryFragment: QueryFragment {
        "\(`operator`)\(separator)(\(base))"
    }
}

struct BinaryOperator<QueryValue>: QueryExpression {
    let lhs: QueryFragment
    let `operator`: QueryFragment
    let rhs: QueryFragment

    init(
        lhs: some QueryExpression,
        operator: QueryFragment,
        rhs: some QueryExpression
    ) {
        self.lhs = lhs.queryFragment
        self.operator = `operator`
        self.rhs = rhs.queryFragment
    }

    var queryFragment: QueryFragment {

        let op: QueryFragment
        if `operator`.debugDescription == "IS" {
            op = "IS NOT DISTINCT FROM"
        } else if `operator`.debugDescription == "IS NOT" {
            op = "IS DISTINCT FROM"
        } else {
            op = `operator`
        }

        let rhsDescription = rhs.debugDescription
        let wrappedRhs: QueryFragment
        if rhsDescription.hasPrefix("(") && rhsDescription.hasSuffix(")") {
            wrappedRhs = rhs
        } else {
            wrappedRhs = "(\(rhs))"
        }

        return "(\(lhs)) \(op) \(wrappedRhs)"
    }
}

struct LikeOperator<
    LHS: QueryExpression<String>,
    RHS: QueryExpression<String>
>: QueryExpression {
    typealias QueryValue = Bool

    let string: LHS
    let pattern: RHS
    let escape: Character?

    var queryFragment: QueryFragment {
        var query: QueryFragment = "(\(string.queryFragment) LIKE \(pattern.queryFragment)"
        if let escape {
            query.append(" ESCAPE \(bind: String(escape))")
        }
        query.append(")")
        return query
    }
}

extension Sequence where Element: QueryExpression, Element.QueryValue: QueryExpression {
    typealias Expression = _SequenceExpression<Self>
}

struct _SequenceExpression<S: Swift.Sequence>: QueryExpression
where S.Element: QueryExpression, S.Element.QueryValue: QueryExpression {
    typealias QueryValue = S
    let queryFragment: QueryFragment
    init(elements: S) {
        let itemsArray = Array(elements)
        if itemsArray.isEmpty {

            queryFragment = "NULL"
        } else {

            let items = itemsArray.map { $0.queryFragment }.joined(separator: ", ")
            queryFragment = "(\(items))"
        }
    }
}
