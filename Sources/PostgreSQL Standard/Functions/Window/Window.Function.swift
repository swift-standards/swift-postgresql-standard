import Foundation
import Structured_Queries_Primitives

extension Window {

    public struct Function<Value: QueryBindable>: QueryExpression {
        public typealias QueryValue = Value

        let functionName: String
        let arguments: [QueryFragment]
        var windowSpec: WindowSpec?

        init(functionName: String, arguments: [QueryFragment]) {
            self.functionName = functionName
            self.arguments = arguments
            self.windowSpec = nil
        }

        public func over() -> some QueryExpression<Value> {
            var copy = self
            copy.windowSpec = WindowSpec()
            return Window.Base<Value>(
                functionName: copy.functionName,
                arguments: copy.arguments,
                windowSpec: copy.windowSpec
            )
        }

        public func over(_ builder: (WindowSpec) -> WindowSpec) -> some QueryExpression<Value> {
            var copy = self
            copy.windowSpec = builder(WindowSpec())
            return Window.Base<Value>(
                functionName: copy.functionName,
                arguments: copy.arguments,
                windowSpec: copy.windowSpec
            )
        }

        public func over(_ windowName: String) -> some QueryExpression<Value> {
            Window.Named<Value>(
                functionName: functionName,
                arguments: arguments,
                windowName: windowName
            )
        }

        public var queryFragment: QueryFragment {
            Window.Base<Value>(
                functionName: functionName,
                arguments: arguments,
                windowSpec: windowSpec
            ).queryFragment
        }
    }
}
