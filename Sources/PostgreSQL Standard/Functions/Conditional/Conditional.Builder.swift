import Structured_Queries_Primitives

extension Conditional {

    public struct Builder<Base, QueryValue: _OptionalProtocol>: QueryExpression {
        var base: QueryFragment?
        var cases: [QueryFragment]

        public func when(
            _ condition: some QueryExpression<Base>,
            then expression: some QueryExpression<QueryValue>
        ) -> Conditional.Builder<Base, QueryValue> {
            var cases = self
            cases.cases.append(
                Conditional.When(
                    predicate: condition.queryFragment,
                    expression: expression.queryFragment
                )
                .queryFragment
            )
            return cases
        }

        public func when(
            _ condition: some QueryExpression<Base>,
            then expression: some QueryExpression<QueryValue.Wrapped>
        ) -> Conditional.Builder<Base, QueryValue> {
            var cases = self
            cases.cases.append(
                Conditional.When(
                    predicate: condition.queryFragment,
                    expression: expression.queryFragment
                )
                .queryFragment
            )
            return cases
        }

        public func `else`(
            _ expression: some QueryExpression<QueryValue.Wrapped>
        ) -> some QueryExpression<QueryValue.Wrapped> {
            var cases = self
            cases.cases.append("ELSE \(expression)")
            return SQLQueryExpression(cases.queryFragment)
        }

        public var queryFragment: QueryFragment {
            var query: QueryFragment = "CASE"
            if let base {
                query.append(" \(base)")
            }
            query.append(" \(cases.joined(separator: " ")) END")
            return query
        }
    }
}
