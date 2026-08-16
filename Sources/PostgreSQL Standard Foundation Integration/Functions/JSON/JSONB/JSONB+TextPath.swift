import PostgreSQL_Standard
import Structured_Queries_Primitives
// `QuoteDelimiter.text`, used by `literalFragment`, is declared here.
import Structured_Queries_Primitives_Support

// MARK: - JSONB.TextPath

extension JSONB {
    /// A PostgreSQL `text[]` path addressing a location inside a JSONB value.
    ///
    /// PostgreSQL spells the path argument of `#>`, `#>>`, `#-`, `jsonb_set`, and
    /// `jsonb_insert` as `text[]`. This type owns the single question of how a Swift
    /// `[String]` reaches that argument position, so no call site has to answer it.
    ///
    /// Two renderings exist because the two argument positions differ in what they admit:
    ///
    /// - ``queryFragment`` binds the whole path as one `text[]` parameter. This is the
    ///   rendering every runtime expression uses — the elements travel as parameter data
    ///   and are never part of the statement text.
    /// - ``literalFragment`` writes the path as a self-contained `text[]` literal, for the
    ///   DDL positions that cannot carry parameters at all (a `CREATE INDEX` expression
    ///   must be a constant). It quotes at both layers the value passes through.
    ///
    /// In both renderings a path element is a value, and an element carrying a comma, a
    /// brace, a quote, or a backslash addresses exactly the key it spells.
    struct TextPath {
        /// The path elements, outermost first.
        let elements: [String]

        init(_ elements: [String]) {
            self.elements = elements
        }
    }
}

extension JSONB.TextPath {
    /// The path as a bound `text[]` parameter.
    ///
    /// The explicit cast keeps the argument's type resolvable in every position, including
    /// an empty path, where an uncast array constructor has no inferable element type.
    var queryFragment: QueryFragment {
        "\(QueryBinding.stringArray(elements))::text[]"
    }

    /// The path as a `text[]` literal, for positions that cannot bind a parameter.
    ///
    /// Use this only where PostgreSQL rejects parameters outright — currently the
    /// `CREATE INDEX` expression positions. Everywhere else, ``queryFragment`` applies.
    var literalFragment: QueryFragment {
        "\(quote: arrayLiteral, delimiter: .text)::text[]"
    }

    /// The PostgreSQL array-literal body for this path, e.g. `{"stats","visits"}`.
    ///
    /// Every element is double-quoted, so a comma, brace, space, or empty element is read
    /// as part of the element rather than as array structure, and an element spelling
    /// `NULL` stays the four-character key. Within the quotes, `"` and `\` are
    /// backslash-escaped, which is the whole of PostgreSQL's array-literal escape grammar.
    ///
    /// This is the array layer only. The result still has to be quoted as a SQL text
    /// literal before it enters a statement, which ``literalFragment`` does.
    var arrayLiteral: String {
        var literal = "{"
        for (index, element) in elements.enumerated() {
            if index > 0 { literal.append(",") }
            literal.append("\"")
            for character in element {
                if character == "\"" || character == "\\" { literal.append("\\") }
                literal.append(character)
            }
            literal.append("\"")
        }
        literal.append("}")
        return literal
    }
}
