import Structured_Queries
import Structured_Queries_Support

extension TableDefinition where QueryValue: FullTextSearchable {

    public func rank(
        by query: some StringProtocol,
        language: String = "english",
        normalization: TextSearch.RankNormalization = .none
    ) -> some QueryExpression<Double> {
        var fragment: QueryFragment = "ts_rank("
        fragment.append("\(quote: QueryValue.tableName).\(quote: QueryValue.searchVectorColumn), ")
        fragment.append(
            "to_tsquery(\(raw: language.quoted(.text))::regconfig, \(bind: "\(query)"))"
        )
        if normalization != .none {
            fragment.append(", \(raw: String(normalization.rawValue))")
        }
        fragment.append(")")
        return SQLQueryExpression(fragment, as: Double.self)
    }

    public func rank(
        byCoverage query: some StringProtocol,
        language: String = "english",
        normalization: TextSearch.RankNormalization = .none
    ) -> some QueryExpression<Double> {
        var fragment: QueryFragment = "ts_rank_cd("
        fragment.append("\(quote: QueryValue.tableName).\(quote: QueryValue.searchVectorColumn), ")
        fragment.append(
            "to_tsquery(\(raw: language.quoted(.text))::regconfig, \(bind: "\(query)"))"
        )
        if normalization != .none {
            fragment.append(", \(raw: String(normalization.rawValue))")
        }
        fragment.append(")")
        return SQLQueryExpression(fragment, as: Double.self)
    }

    public func rank(
        by query: some StringProtocol,
        weights: [Double],
        language: String = "english",
        normalization: TextSearch.RankNormalization = .none
    ) -> some QueryExpression<Double> {
        precondition(weights.count == 4, "Weights array must have exactly 4 elements [D, C, B, A]")

        var fragment: QueryFragment = "ts_rank("

        let weightsStr: String = weights.map { String($0) }.joined(separator: ", ")
        fragment.append("ARRAY[\(raw: weightsStr)], ")

        fragment.append("\(quote: QueryValue.tableName).\(quote: QueryValue.searchVectorColumn), ")
        fragment.append(
            "to_tsquery(\(raw: language.quoted(.text))::regconfig, \(bind: "\(query)"))"
        )

        if normalization != .none {
            fragment.append(", \(raw: String(normalization.rawValue))")
        }
        fragment.append(")")

        return SQLQueryExpression(fragment, as: Double.self)
    }

    public func rank(
        byCoverage query: some StringProtocol,
        weights: [Double],
        language: String = "english",
        normalization: TextSearch.RankNormalization = .none
    ) -> some QueryExpression<Double> {
        precondition(weights.count == 4, "Weights array must have exactly 4 elements [D, C, B, A]")

        var fragment: QueryFragment = "ts_rank_cd("

        let weightsStr: String = weights.map { String($0) }.joined(separator: ", ")
        fragment.append("ARRAY[\(raw: weightsStr)], ")

        fragment.append("\(quote: QueryValue.tableName).\(quote: QueryValue.searchVectorColumn), ")
        fragment.append(
            "to_tsquery(\(raw: language.quoted(.text))::regconfig, \(bind: "\(query)"))"
        )

        if normalization != .none {
            fragment.append(", \(raw: String(normalization.rawValue))")
        }
        fragment.append(")")

        return SQLQueryExpression(fragment, as: Double.self)
    }
}

extension TableColumnExpression where Value == TextSearch.Vector {

    public func rank(
        by query: some StringProtocol,
        language: String = "english",
        normalization: TextSearch.RankNormalization = .none
    ) -> some QueryExpression<Double> {
        var fragment: QueryFragment = "ts_rank("
        fragment.append("\(self.queryFragment), ")
        fragment.append(
            "to_tsquery(\(raw: language.quoted(.text))::regconfig, \(bind: "\(query)"))"
        )
        if normalization != .none {
            fragment.append(", \(raw: String(normalization.rawValue))")
        }
        fragment.append(")")
        return SQLQueryExpression(fragment, as: Double.self)
    }

    public func rank(
        by query: some StringProtocol,
        weights: [Double],
        language: String = "english",
        normalization: TextSearch.RankNormalization = .none
    ) -> some QueryExpression<Double> {
        precondition(weights.count == 4, "Weights array must have exactly 4 elements [D, C, B, A]")

        var fragment: QueryFragment = "ts_rank("

        let weightsStr: String = weights.map { String($0) }.joined(separator: ", ")
        fragment.append("ARRAY[\(raw: weightsStr)], ")

        fragment.append("\(self.queryFragment), ")
        fragment.append(
            "to_tsquery(\(raw: language.quoted(.text))::regconfig, \(bind: "\(query)"))"
        )

        if normalization != .none {
            fragment.append(", \(raw: String(normalization.rawValue))")
        }
        fragment.append(")")

        return SQLQueryExpression(fragment, as: Double.self)
    }
}
