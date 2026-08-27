import Structured_Queries
import Structured_Queries_Support

extension JSONB {

    struct TextPath {

        let elements: [String]

        init(_ elements: [String]) {
            self.elements = elements
        }
    }
}

extension JSONB.TextPath {

    var queryFragment: QueryFragment {
        "\(QueryBinding.stringArray(elements))::text[]"
    }

    var literalFragment: QueryFragment {
        "\(quote: arrayLiteral, delimiter: .text)::text[]"
    }

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
