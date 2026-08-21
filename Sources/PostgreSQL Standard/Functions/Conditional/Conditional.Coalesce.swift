import Foundation
import Structured_Queries_Primitives

extension Conditional {

    public struct Coalesce<QueryValue>: QueryExpression {
        private let arguments: [QueryFragment]

        fileprivate init(_ arguments: [QueryFragment]) {
            self.arguments = arguments
        }

        public var queryFragment: QueryFragment {
            "coalesce(\(arguments.joined(separator: ", ")))"
        }

        public static func ?? <T: _OptionalProtocol<QueryValue>>(
            lhs: some QueryExpression<T>,
            rhs: Self
        ) -> Coalesce<QueryValue> {
            Self([lhs.queryFragment] + rhs.arguments)
        }
    }
}

extension Conditional.Coalesce where QueryValue: _OptionalProtocol {
    public static func ?? (
        lhs: some QueryExpression<QueryValue>,
        rhs: Self
    ) -> Self {
        Self([lhs.queryFragment] + rhs.arguments)
    }
}

extension QueryExpression where QueryValue: _OptionalProtocol {

    public func ifnull(
        _ other: some QueryExpression<QueryValue.Wrapped>
    ) -> some QueryExpression<QueryValue.Wrapped> {
        QueryFunction("ifnull", self, other)
    }

    public func ifnull(
        _ other: some QueryExpression<QueryValue>
    ) -> some QueryExpression<QueryValue> {
        QueryFunction("ifnull", self, other)
    }

    public static func ?? (
        lhs: Self,
        rhs: some QueryExpression<QueryValue.Wrapped>
    ) -> Conditional.Coalesce<QueryValue.Wrapped> {
        Conditional.Coalesce([lhs.queryFragment, rhs.queryFragment])
    }

    public static func ?? (
        lhs: Self,
        rhs: some QueryExpression<QueryValue>
    ) -> Conditional.Coalesce<QueryValue> {
        Conditional.Coalesce([lhs.queryFragment, rhs.queryFragment])
    }

    @_documentation(visibility: private)
    @available(
        *,
        deprecated,
        message:
            "Left side of 'NULL' coalescing operator '??' has non-optional query type, so the right side is never used"
    )
    public static func ?? (
        lhs: some QueryExpression<QueryValue.Wrapped>,
        rhs: Self
    ) -> Conditional.Coalesce<QueryValue> {
        Conditional.Coalesce([lhs.queryFragment, rhs.queryFragment])
    }
}

extension QueryExpression {
    @_documentation(visibility: private)
    @available(
        *,
        deprecated,
        message:
            "Left side of 'NULL' coalescing operator '??' has non-optional query type, so the right side is never used"
    )
    public static func ?? (
        lhs: some QueryExpression<QueryValue>,
        rhs: Self
    ) -> Conditional.Coalesce<QueryValue> {
        Conditional.Coalesce([lhs.queryFragment, rhs.queryFragment])
    }
}
