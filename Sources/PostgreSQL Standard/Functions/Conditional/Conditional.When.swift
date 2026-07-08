import Structured_Queries_Primitives

extension Conditional {
    /// A WHEN...THEN clause for CASE expressions.
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
