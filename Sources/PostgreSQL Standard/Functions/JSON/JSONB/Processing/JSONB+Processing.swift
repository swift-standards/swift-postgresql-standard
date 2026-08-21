import Foundation
import Structured_Queries_Primitives

extension JSONB {

    public enum Processing {}
}

extension JSONB.Processing {

    public struct Pretty<LHS: QueryExpression>: QueryExpression {
        public typealias QueryValue = String

        let jsonb: LHS

        public var queryFragment: QueryFragment {
            "jsonb_pretty(\(jsonb.queryFragment))"
        }
    }

    public struct TypeOf<LHS: QueryExpression>: QueryExpression {
        public typealias QueryValue = String

        let jsonb: LHS

        public var queryFragment: QueryFragment {
            "jsonb_typeof(\(jsonb.queryFragment))"
        }
    }

    public struct ArrayLength<LHS: QueryExpression>: QueryExpression {
        public typealias QueryValue = Int

        let jsonb: LHS

        public var queryFragment: QueryFragment {
            "jsonb_array_length(\(jsonb.queryFragment))"
        }
    }
}
