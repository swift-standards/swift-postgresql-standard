import Structured_Queries
import Structured_Queries_Support

extension TableDefinition where QueryValue: FullTextSearchable {

    public func match(
        _ query: some StringProtocol,
        language: String = "english"
    ) -> some QueryExpression<Bool> {
        SQLQueryExpression(
            """
            \(quote: QueryValue.tableName).\(quote: QueryValue.searchVectorColumn) @@ \
            to_tsquery(\(raw: language.quoted(.text))::regconfig, \(bind: "\(query)"))
            """,
            as: Bool.self
        )
    }

    public func plainMatch(
        _ text: some StringProtocol,
        language: String = "english"
    ) -> some QueryExpression<Bool> {
        SQLQueryExpression(
            """
            \(quote: QueryValue.tableName).\(quote: QueryValue.searchVectorColumn) @@ \
            plainto_tsquery(\(raw: language.quoted(.text))::regconfig, \(bind: "\(text)"))
            """,
            as: Bool.self
        )
    }

    public func webMatch(
        _ query: some StringProtocol,
        language: String = "english"
    ) -> some QueryExpression<Bool> {
        SQLQueryExpression(
            """
            \(quote: QueryValue.tableName).\(quote: QueryValue.searchVectorColumn) @@ \
            websearch_to_tsquery(\(raw: language.quoted(.text))::regconfig, \(bind: "\(query)"))
            """,
            as: Bool.self
        )
    }

    public func phraseMatch(
        _ phrase: some StringProtocol,
        language: String = "english"
    ) -> some QueryExpression<Bool> {
        SQLQueryExpression(
            """
            \(quote: QueryValue.tableName).\(quote: QueryValue.searchVectorColumn) @@ \
            phraseto_tsquery(\(raw: language.quoted(.text))::regconfig, \(bind: "\(phrase)"))
            """,
            as: Bool.self
        )
    }
}

extension TableColumnExpression where Value == String {

    public func searchVector(_ language: String = "english") -> some QueryExpression<String> {
        SQLQueryExpression(
            "to_tsvector(\(raw: language.quoted(.text))::regconfig, \(self.queryFragment))",
            as: String.self
        )
    }

    public func match(
        _ query: some StringProtocol,
        language: String = "english"
    ) -> some QueryExpression<Bool> {
        SQLQueryExpression(
            """
            to_tsvector(\(raw: language.quoted(.text))::regconfig, \(self.queryFragment)) @@ \
            to_tsquery(\(raw: language.quoted(.text))::regconfig, \(bind: "\(query)"))
            """,
            as: Bool.self
        )
    }
}
