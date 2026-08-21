import Structured_Queries_Primitives

extension QueryExpression where QueryValue == String {

    public static func + (
        lhs: Self,
        rhs: some QueryExpression<QueryValue>
    ) -> some QueryExpression<QueryValue> {
        BinaryOperator(lhs: lhs, operator: "||", rhs: rhs)
    }

    public func collate(_ collation: Collation) -> some QueryExpression<QueryValue> {
        SQLQueryExpression("\(self) COLLATE \(collation)")
    }

    public func glob(_ pattern: some StringProtocol) -> some QueryExpression<Bool> {
        BinaryOperator(lhs: self, operator: "GLOB", rhs: "\(pattern)")
    }

    public func like(
        _ pattern: some StringProtocol,
        escape: Character? = nil
    ) -> some QueryExpression<Bool> {
        LikeOperator(string: self, pattern: "\(pattern)", escape: escape)
    }

    public func hasPrefix(_ other: some StringProtocol) -> some QueryExpression<Bool> {
        like("\(other)%")
    }

    public func hasSuffix(_ other: some StringProtocol) -> some QueryExpression<Bool> {
        like("%\(other)")
    }

    @_disfavoredOverload
    public func contains(_ other: some StringProtocol) -> some QueryExpression<Bool> {
        like("%\(other)%")
    }
}

extension SQLQueryExpression<String> {

    public static func += (
        lhs: inout Self,
        rhs: some QueryExpression<QueryValue>
    ) {
        lhs = Self(lhs + rhs)
    }

    public mutating func append(_ other: some QueryExpression<QueryValue>) {
        self += other
    }

    public mutating func append(contentsOf other: some QueryExpression<QueryValue>) {
        self += other
    }
}
