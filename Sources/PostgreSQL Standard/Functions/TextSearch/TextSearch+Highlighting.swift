import Foundation
import Structured_Queries
import Structured_Queries_Support

extension TableColumnExpression where Value == String {

    public func headline(
        matching query: some StringProtocol,
        language: String = "english",
        startDelimiter: String = "<b>",
        stopDelimiter: String = "</b>",
        wordRange: TextSearch.WordRange? = nil,
        shortWord: Int? = nil,
        maxFragments: Int? = nil
    ) -> some QueryExpression<String> {

        func escapeDelimiter(_ s: String) -> String {
            s.replacingOccurrences(of: "'", with: "''")
                .replacingOccurrences(of: ",", with: "")
        }

        var options: [String] = [
            "StartSel=\(escapeDelimiter(startDelimiter))",
            "StopSel=\(escapeDelimiter(stopDelimiter))",
        ]

        if let wordRange {
            options.append("MinWords=\(wordRange.min)")
            options.append("MaxWords=\(wordRange.max)")
        }

        if let shortWord {
            options.append("ShortWord=\(shortWord)")
        }
        if let maxFragments {
            options.append("MaxFragments=\(maxFragments)")
        }

        let optionsString = options.joined(separator: ", ")

        return SQLQueryExpression(
            """
            ts_headline(\
            \(raw: language.quoted(.text))::regconfig, \
            \(self.queryFragment), \
            to_tsquery(\(raw: language.quoted(.text))::regconfig, \(bind: "\(query)")), \
            \(raw: optionsString.quoted(.text))\
            )
            """,
            as: String.self
        )
    }
}
