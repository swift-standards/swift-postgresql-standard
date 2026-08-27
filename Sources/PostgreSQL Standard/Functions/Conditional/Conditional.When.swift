import Structured_Queries

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
