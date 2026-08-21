public import Foundation
public import Structured_Queries_Primitives

extension JSONB {

    public enum Operators {}
}

extension JSONB.Operators {

    public struct Field<LHS: QueryExpression>: QueryExpression {
        public typealias QueryValue = Data

        let jsonb: LHS
        let key: String

        public var queryFragment: QueryFragment {
            "(\(jsonb.queryFragment) -> \(bind: key))"
        }
    }

    public struct FieldText<LHS: QueryExpression>: QueryExpression {
        public typealias QueryValue = String?

        let jsonb: LHS
        let key: String

        public var queryFragment: QueryFragment {
            "(\(jsonb.queryFragment) ->> \(bind: key))"
        }
    }

    public struct Index<LHS: QueryExpression>: QueryExpression {
        public typealias QueryValue = Data

        let jsonb: LHS
        let index: Int

        public var queryFragment: QueryFragment {
            "(\(jsonb.queryFragment) -> \(index))"
        }
    }

    public struct IndexText<LHS: QueryExpression>: QueryExpression {
        public typealias QueryValue = String?

        let jsonb: LHS
        let index: Int

        public var queryFragment: QueryFragment {
            "(\(jsonb.queryFragment) ->> \(index))"
        }
    }

    public struct Path<LHS: QueryExpression>: QueryExpression {
        public typealias QueryValue = Data

        let jsonb: LHS
        let path: [String]

        public var queryFragment: QueryFragment {
            "(\(jsonb.queryFragment) #> \(JSONB.TextPath(path).queryFragment))"
        }
    }

    public struct PathText<LHS: QueryExpression>: QueryExpression {
        public typealias QueryValue = String?

        let jsonb: LHS
        let path: [String]

        public var queryFragment: QueryFragment {
            "(\(jsonb.queryFragment) #>> \(JSONB.TextPath(path).queryFragment))"
        }
    }
}

extension JSONB.Operators.Field {
    public func field(_ key: String) -> JSONB.Operators.Field<Self> {
        JSONB.Operators.Field<Self>(jsonb: self, key: key)
    }

    public func fieldAsText(_ key: String) -> JSONB.Operators.FieldText<Self> {
        JSONB.Operators.FieldText<Self>(jsonb: self, key: key)
    }
}

extension JSONB.Operators.Path {
    public func field(_ key: String) -> JSONB.Operators.Field<Self> {
        JSONB.Operators.Field<Self>(jsonb: self, key: key)
    }

    public func fieldAsText(_ key: String) -> JSONB.Operators.FieldText<Self> {
        JSONB.Operators.FieldText<Self>(jsonb: self, key: key)
    }
}
