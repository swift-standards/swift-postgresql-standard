import Foundation
import Structured_Queries_Primitives

extension QueryExpression where QueryValue == String {

    public func similarTo(
        _ pattern: some StringProtocol,
        escape: Character? = nil
    ) -> some QueryExpression<Bool> {
        SimilarToOperator(string: self, pattern: "\(pattern)", escape: escape)
    }

    public func notSimilarTo(
        _ pattern: some StringProtocol,
        escape: Character? = nil
    ) -> some QueryExpression<Bool> {
        NotSimilarToOperator(string: self, pattern: "\(pattern)", escape: escape)
    }
}

extension QueryExpression where QueryValue == String {

    public func regexMatch(_ pattern: some StringProtocol) -> some QueryExpression<Bool> {
        RegexMatchOperator(string: self, pattern: "\(pattern)")
    }

    public func regexMatchCaseInsensitive(
        _ pattern: some StringProtocol
    ) -> some QueryExpression<
        Bool
    > {
        RegexMatchCaseInsensitiveOperator(string: self, pattern: "\(pattern)")
    }

    public func regexNotMatch(_ pattern: some StringProtocol) -> some QueryExpression<Bool> {
        RegexNotMatchOperator(string: self, pattern: "\(pattern)")
    }

    public func regexNotMatchCaseInsensitive(
        _ pattern: some StringProtocol
    )
        -> some QueryExpression<Bool>
    {
        RegexNotMatchCaseInsensitiveOperator(string: self, pattern: "\(pattern)")
    }
}

extension QueryExpression where QueryValue == String {

    public func regexpLike(
        _ pattern: some StringProtocol,
        flags: String? = nil
    ) -> some QueryExpression<Bool> {
        if let flags {
            return SQLQueryExpression(
                "regexp_like(\(self.queryFragment), \(bind: String(pattern)), \(bind: flags))",
                as: Bool.self
            )
        } else {
            return SQLQueryExpression(
                "regexp_like(\(self.queryFragment), \(bind: String(pattern)))",
                as: Bool.self
            )
        }
    }

    public func regexpCount(
        _ pattern: some StringProtocol,
        start: Int? = nil,
        flags: String? = nil
    ) -> some QueryExpression<Int> {
        if let start, let flags {
            return SQLQueryExpression(
                "regexp_count(\(self.queryFragment), \(bind: String(pattern)), \(start), \(bind: flags))",
                as: Int.self
            )
        } else if let start {
            return SQLQueryExpression(
                "regexp_count(\(self.queryFragment), \(bind: String(pattern)), \(start))",
                as: Int.self
            )
        } else if let flags {
            return SQLQueryExpression(
                "regexp_count(\(self.queryFragment), \(bind: String(pattern)), 1, \(bind: flags))",
                as: Int.self
            )
        } else {
            return SQLQueryExpression(
                "regexp_count(\(self.queryFragment), \(bind: String(pattern)))",
                as: Int.self
            )
        }
    }

    public func regexpInstr(
        _ pattern: some StringProtocol,
        start: Int? = nil,
        occurrence n: Int? = nil,
        flags: String? = nil
    ) -> some QueryExpression<Int> {
        if let start, let n, let flags {
            return SQLQueryExpression(
                "regexp_instr(\(self.queryFragment), \(bind: String(pattern)), \(start), \(n), \(bind: flags))",
                as: Int.self
            )
        } else if let start, let n {
            return SQLQueryExpression(
                "regexp_instr(\(self.queryFragment), \(bind: String(pattern)), \(start), \(n))",
                as: Int.self
            )
        } else if let start, let flags {
            return SQLQueryExpression(
                "regexp_instr(\(self.queryFragment), \(bind: String(pattern)), \(start), 1, \(bind: flags))",
                as: Int.self
            )
        } else if let start {
            return SQLQueryExpression(
                "regexp_instr(\(self.queryFragment), \(bind: String(pattern)), \(start))",
                as: Int.self
            )
        } else if let n, let flags {
            return SQLQueryExpression(
                "regexp_instr(\(self.queryFragment), \(bind: String(pattern)), 1, \(n), \(bind: flags))",
                as: Int.self
            )
        } else if let n {
            return SQLQueryExpression(
                "regexp_instr(\(self.queryFragment), \(bind: String(pattern)), 1, \(n))",
                as: Int.self
            )
        } else if let flags {
            return SQLQueryExpression(
                "regexp_instr(\(self.queryFragment), \(bind: String(pattern)), 1, 1, \(bind: flags))",
                as: Int.self
            )
        } else {
            return SQLQueryExpression(
                "regexp_instr(\(self.queryFragment), \(bind: String(pattern)))",
                as: Int.self
            )
        }
    }

    public func regexpReplace(
        _ pattern: some StringProtocol,
        _ replacement: some StringProtocol,
        start: Int? = nil,
        flags: String? = nil
    ) -> some QueryExpression<String> {
        if let start, let flags {
            return SQLQueryExpression(
                "regexp_replace(\(self.queryFragment), \(bind: String(pattern)), \(bind: String(replacement)), \(start), \(bind: flags))",
                as: String.self
            )
        } else if let start {
            return SQLQueryExpression(
                "regexp_replace(\(self.queryFragment), \(bind: String(pattern)), \(bind: String(replacement)), \(start))",
                as: String.self
            )
        } else if let flags {
            return SQLQueryExpression(
                "regexp_replace(\(self.queryFragment), \(bind: String(pattern)), \(bind: String(replacement)), 1, \(bind: flags))",
                as: String.self
            )
        } else {
            return SQLQueryExpression(
                "regexp_replace(\(self.queryFragment), \(bind: String(pattern)), \(bind: String(replacement)))",
                as: String.self
            )
        }
    }

    public func regexpSubstr(
        _ pattern: some StringProtocol,
        start: Int? = nil,
        occurrence n: Int? = nil,
        flags: String? = nil
    ) -> some QueryExpression<String?> {
        if let start, let n, let flags {
            return SQLQueryExpression(
                "regexp_substr(\(self.queryFragment), \(bind: String(pattern)), \(start), \(n), \(bind: flags))",
                as: String?.self
            )
        } else if let start, let n {
            return SQLQueryExpression(
                "regexp_substr(\(self.queryFragment), \(bind: String(pattern)), \(start), \(n))",
                as: String?.self
            )
        } else if let start, let flags {
            return SQLQueryExpression(
                "regexp_substr(\(self.queryFragment), \(bind: String(pattern)), \(start), 1, \(bind: flags))",
                as: String?.self
            )
        } else if let start {
            return SQLQueryExpression(
                "regexp_substr(\(self.queryFragment), \(bind: String(pattern)), \(start))",
                as: String?.self
            )
        } else if let n, let flags {
            return SQLQueryExpression(
                "regexp_substr(\(self.queryFragment), \(bind: String(pattern)), 1, \(n), \(bind: flags))",
                as: String?.self
            )
        } else if let n {
            return SQLQueryExpression(
                "regexp_substr(\(self.queryFragment), \(bind: String(pattern)), 1, \(n))",
                as: String?.self
            )
        } else if let flags {
            return SQLQueryExpression(
                "regexp_substr(\(self.queryFragment), \(bind: String(pattern)), 1, 1, \(bind: flags))",
                as: String?.self
            )
        } else {
            return SQLQueryExpression(
                "regexp_substr(\(self.queryFragment), \(bind: String(pattern)))",
                as: String?.self
            )
        }
    }
}

private struct SimilarToOperator<
    LHS: QueryExpression<String>,
    RHS: QueryExpression<String>
>: QueryExpression {
    typealias QueryValue = Bool

    let string: LHS
    let pattern: RHS
    let escape: Character?

    var queryFragment: QueryFragment {
        var query: QueryFragment = "(\(string.queryFragment) SIMILAR TO \(pattern.queryFragment)"
        if let escape {
            query.append(" ESCAPE \(bind: String(escape))")
        }
        query.append(")")
        return query
    }
}

private struct NotSimilarToOperator<
    LHS: QueryExpression<String>,
    RHS: QueryExpression<String>
>: QueryExpression {
    typealias QueryValue = Bool

    let string: LHS
    let pattern: RHS
    let escape: Character?

    var queryFragment: QueryFragment {
        var query: QueryFragment =
            "(\(string.queryFragment) NOT SIMILAR TO \(pattern.queryFragment)"
        if let escape {
            query.append(" ESCAPE \(bind: String(escape))")
        }
        query.append(")")
        return query
    }
}

private struct RegexMatchOperator<
    LHS: QueryExpression<String>,
    RHS: QueryExpression<String>
>: QueryExpression {
    typealias QueryValue = Bool

    let string: LHS
    let pattern: RHS

    var queryFragment: QueryFragment {
        "(\(string.queryFragment) ~ \(pattern.queryFragment))"
    }
}

private struct RegexMatchCaseInsensitiveOperator<
    LHS: QueryExpression<String>,
    RHS: QueryExpression<String>
>: QueryExpression {
    typealias QueryValue = Bool

    let string: LHS
    let pattern: RHS

    var queryFragment: QueryFragment {
        "(\(string.queryFragment) ~* \(pattern.queryFragment))"
    }
}

private struct RegexNotMatchOperator<
    LHS: QueryExpression<String>,
    RHS: QueryExpression<String>
>: QueryExpression {
    typealias QueryValue = Bool

    let string: LHS
    let pattern: RHS

    var queryFragment: QueryFragment {
        "(\(string.queryFragment) !~ \(pattern.queryFragment))"
    }
}

private struct RegexNotMatchCaseInsensitiveOperator<
    LHS: QueryExpression<String>,
    RHS: QueryExpression<String>
>: QueryExpression {
    typealias QueryValue = Bool

    let string: LHS
    let pattern: RHS

    var queryFragment: QueryFragment {
        "(\(string.queryFragment) !~* \(pattern.queryFragment))"
    }
}
