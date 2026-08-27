import Foundation
import Structured_Queries

extension Trigger {
    public struct Function: Sendable, Statement {

        public let name: String

        public let orReplace: Bool

        private let body: QueryFragment

        init(name: String, body: QueryFragment, orReplace: Bool = true) {
            self.name = name
            self.body = body
            self.orReplace = orReplace
        }
    }
}

extension Trigger.Function {
    public typealias From = Never
    public typealias Joins = ()
    public typealias QueryValue = ()

    public var query: QueryFragment {
        var query: QueryFragment = "CREATE"
        if orReplace {
            query.append(" OR REPLACE")
        }
        query.append(" FUNCTION \(quote: name)()")
        query.append("\(.newline)RETURNS TRIGGER AS $$")
        query.append("\(.newline)\(generateBody())")
        query.append("\(.newline)$$ LANGUAGE plpgsql")
        return query
    }

    private func generateBody() -> QueryFragment {

        let bodyString = body.debugDescription
        let trimmed = bodyString.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.uppercased().hasPrefix("BEGIN") {
            return body
        } else {
            var result: QueryFragment = "BEGIN"
            result.append("\(.newline)\(body.indented())")
            result.append("\(.newline)END")
            return result
        }
    }

    public func drop(ifExists: Bool = false, cascade: Bool = false) -> some Statement<()> {
        var query: QueryFragment = "DROP FUNCTION"
        if ifExists {
            query.append(" IF EXISTS")
        }
        query.append(" \(quote: name)()")
        if cascade {
            query.append(" CASCADE")
        }
        return SQLQueryExpression(query)
    }
}

extension Trigger.Function {

    public static func define(
        _ name: String,
        orReplace: Bool = true,
        @QueryFragmentBuilder<any Statement> performs body: () -> [QueryFragment]
    ) -> Self {
        let statements = body()
        var bodyFragment = statements.joined(separator: ";\(.newlineOrSpace)")

        bodyFragment.append(";")
        return Self(name: name, body: bodyFragment, orReplace: orReplace)
    }

    @_disfavoredOverload
    public static func define(
        _ name: String,
        orReplace: Bool = true,
        performs body: QueryFragment
    ) -> Self {
        Self(name: name, body: body, orReplace: orReplace)
    }

    @_disfavoredOverload
    public static func plpgsql(
        _ name: String,
        orReplace: Bool = true,
        @QueryFragmentBuilder<any Statement> _ body: () -> [QueryFragment]
    ) -> Self {
        define(name, orReplace: orReplace, performs: body)
    }

    @_disfavoredOverload
    public static func plpgsql(
        _ name: String,
        orReplace: Bool = true,
        _ body: QueryFragment
    ) -> Self {
        define(name, orReplace: orReplace, performs: body)
    }
}
