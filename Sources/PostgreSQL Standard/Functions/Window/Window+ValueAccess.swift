import Foundation
import Structured_Queries

extension QueryExpression {

    public func lag(
        offset: Int = 1,
        default defaultValue: QueryValue? = nil
    ) -> Window.Function<QueryValue?> where QueryValue: QueryBindable {
        var args: [QueryFragment] = [self.queryFragment, QueryFragment(stringLiteral: "\(offset)")]
        if let defaultValue {
            args.append("\(bind: defaultValue)")
        }
        return Window.Function(functionName: "LAG", arguments: args)
    }

    public func lead(
        offset: Int = 1,
        default defaultValue: QueryValue? = nil
    ) -> Window.Function<QueryValue?> where QueryValue: QueryBindable {
        var args: [QueryFragment] = [self.queryFragment, QueryFragment(stringLiteral: "\(offset)")]
        if let defaultValue {
            args.append("\(bind: defaultValue)")
        }
        return Window.Function(functionName: "LEAD", arguments: args)
    }

    public func firstValue() -> Window.Function<QueryValue> where QueryValue: QueryBindable {
        Window.Function(functionName: "FIRST_VALUE", arguments: [self.queryFragment])
    }

    public func lastValue() -> Window.Function<QueryValue> where QueryValue: QueryBindable {
        Window.Function(functionName: "LAST_VALUE", arguments: [self.queryFragment])
    }

    public func nthValue(_ n: Int) -> Window.Function<QueryValue?>
    where QueryValue: QueryBindable {
        precondition(n > 0, "nth value position must be positive (1-indexed)")
        return Window.Function(
            functionName: "NTH_VALUE",
            arguments: [self.queryFragment, QueryFragment(stringLiteral: "\(n)")]
        )
    }
}
