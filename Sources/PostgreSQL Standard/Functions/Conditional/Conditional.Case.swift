import Structured_Queries

extension Conditional {

    public struct Case<Base, QueryValue: _OptionalPromotable> {
        var base: QueryFragment?

        public init(
            _ base: some QueryExpression<Base>
        ) {
            self.base = base.queryFragment
        }

        public init() where Base == Bool {}

        public func when(
            _ condition: some QueryExpression<Base>,
            then expression: some QueryExpression<QueryValue>
        ) -> Conditional.Builder<Base, QueryValue?> {
            Conditional.Builder(
                base: base,
                cases: [
                    Conditional.When(
                        predicate: condition.queryFragment,
                        expression: expression.queryFragment
                    )
                    .queryFragment
                ]
            )
        }

        public func when(
            _ condition: some QueryExpression<Base>,
            then expression: some QueryExpression<QueryValue._Optionalized>
        ) -> Conditional.Builder<Base, QueryValue._Optionalized> {
            Conditional.Builder(
                base: base,
                cases: [
                    Conditional.When(
                        predicate: condition.queryFragment,
                        expression: expression.queryFragment
                    )
                    .queryFragment
                ]
            )
        }
    }
}
