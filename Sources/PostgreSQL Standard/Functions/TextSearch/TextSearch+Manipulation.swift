import Structured_Queries

extension QueryExpression where QueryValue == String {

    public func weighted(_ weight: TextSearch.Weight) -> some QueryExpression<String> {
        SQLQueryExpression(
            "setweight(\(self.queryFragment), \(bind: weight.rawValue))",
            as: String.self
        )
    }

    public var lexemeCount: some QueryExpression<Int> {
        SQLQueryExpression(
            "length(\(self.queryFragment))",
            as: Int.self
        )
    }

    public func stripped() -> some QueryExpression<String> {
        SQLQueryExpression(
            "strip(\(self.queryFragment))",
            as: String.self
        )
    }
}
