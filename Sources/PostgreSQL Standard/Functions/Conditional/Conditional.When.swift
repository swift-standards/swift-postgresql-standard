import Structured_Queries_Primitives

extension Conditional {

    struct When: QueryExpression {
        let predicate: QueryFragment
        let expression: QueryFragment
    }
}

extension Conditional.When {
    typealias QueryValue = Never

    public var queryFragment: QueryFragment {
        "WHEN \(predicate) THEN \(expression)"
    }
}
