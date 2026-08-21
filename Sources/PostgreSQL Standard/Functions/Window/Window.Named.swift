import Foundation
import Structured_Queries_Primitives

extension Window {

    struct Named<Value: QueryBindable>: QueryExpression {
        typealias QueryValue = Value

        let functionName: String
        let arguments: [QueryFragment]
        let windowName: String

        var queryFragment: QueryFragment {
            var fragment: QueryFragment = "\(raw: functionName)("
            if !arguments.isEmpty {
                fragment.append(arguments.joined(separator: ", "))
            }
            fragment.append(")")
            fragment.append(" OVER \(raw: windowName)")
            return fragment
        }
    }
}
