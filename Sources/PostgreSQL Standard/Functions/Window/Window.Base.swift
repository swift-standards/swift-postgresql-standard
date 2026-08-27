import Foundation
import Structured_Queries

extension Window {

    struct Base<Value: QueryBindable>: QueryExpression {
        typealias QueryValue = Value

        let functionName: String
        let arguments: [QueryFragment]
        let windowSpec: WindowSpec?

        var queryFragment: QueryFragment {
            var fragment: QueryFragment = "\(raw: functionName)("
            if !arguments.isEmpty {
                fragment.append(arguments.joined(separator: ", "))
            }
            fragment.append(")")

            if let windowSpec {
                fragment.append(" ")
                fragment.append(windowSpec.generateOverClause())
            } else {
                fragment.append(" OVER ()")
            }

            return fragment
        }
    }
}
