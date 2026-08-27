public import Foundation
import Structured_Queries

extension JSONB {

    public enum AdditionalOperators {}
}

extension JSONB.AdditionalOperators {

    public struct Contains<LHS: QueryExpression>: QueryExpression {
        public typealias QueryValue = Bool

        let lhs: LHS
        let rhs: Foundation.Data

        init(lhs: LHS, rhs: some Encodable) {
            self.lhs = lhs
            do {
                self.rhs = try jsonbEncoder.encode(rhs)
            } catch {
                self.rhs = Data()
            }
        }

        public var queryFragment: QueryFragment {
            let jsonString = String(data: rhs, encoding: .utf8) ?? "{}"
            return "(\(lhs.queryFragment) @> \(bind: jsonString)::jsonb)"
        }
    }

    public struct ContainedBy<LHS: QueryExpression>: QueryExpression {
        public typealias QueryValue = Bool

        let lhs: LHS
        let rhs: Foundation.Data

        init(lhs: LHS, rhs: some Encodable) {
            self.lhs = lhs
            do {
                self.rhs = try jsonbEncoder.encode(rhs)
            } catch {
                self.rhs = Data()
            }
        }

        public var queryFragment: QueryFragment {
            let jsonString = String(data: rhs, encoding: .utf8) ?? "{}"
            return "(\(lhs.queryFragment) <@ \(bind: jsonString)::jsonb)"
        }
    }
}

extension JSONB.AdditionalOperators {

    public enum Keys {

        public struct Exists<LHS: QueryExpression>: QueryExpression {
            public typealias QueryValue = Bool

            let jsonb: LHS
            let key: String

            public var queryFragment: QueryFragment {
                "(\(jsonb.queryFragment) ? \(bind: key))"
            }
        }

        public struct AnyExist<LHS: QueryExpression>: QueryExpression {
            public typealias QueryValue = Bool

            let jsonb: LHS
            let keys: [String]

            public var queryFragment: QueryFragment {
                var arrayFragment: QueryFragment = "ARRAY["
                for (index, key) in keys.enumerated() {
                    if index > 0 {
                        arrayFragment.append(", ")
                    }
                    arrayFragment.append("\(bind: key)")
                }
                arrayFragment.append("]")
                return "(\(jsonb.queryFragment) ?| \(arrayFragment))"
            }
        }

        public struct AllExist<LHS: QueryExpression>: QueryExpression {
            public typealias QueryValue = Bool

            let jsonb: LHS
            let keys: [String]

            public var queryFragment: QueryFragment {
                var arrayFragment: QueryFragment = "ARRAY["
                for (index, key) in keys.enumerated() {
                    if index > 0 {
                        arrayFragment.append(", ")
                    }
                    arrayFragment.append("\(bind: key)")
                }
                arrayFragment.append("]")
                return "(\(jsonb.queryFragment) ?& \(arrayFragment))"
            }
        }
    }
}

extension JSONB.AdditionalOperators {

    public struct Concat<LHS: QueryExpression>: QueryExpression {
        public typealias QueryValue = Data

        let lhs: LHS
        let rhs: Foundation.Data

        init(lhs: LHS, rhs: some Encodable) {
            self.lhs = lhs
            do {
                self.rhs = try jsonbEncoder.encode(rhs)
            } catch {
                self.rhs = Data()
            }
        }

        public var queryFragment: QueryFragment {
            let jsonString = String(data: rhs, encoding: .utf8) ?? "{}"
            return "(\(lhs.queryFragment) || \(bind: jsonString)::jsonb)"
        }
    }

    public struct TypedConcat<LHS: QueryExpression, Value: _JSONBRepresentationProtocol>:
        QueryExpression
    {
        public typealias QueryValue = Value

        let lhs: LHS
        let rhs: Foundation.Data

        init(lhs: LHS, rhs: some Encodable) {
            self.lhs = lhs
            do {
                self.rhs = try jsonbEncoder.encode(rhs)
            } catch {
                self.rhs = Data()
            }
        }

        public var queryFragment: QueryFragment {
            let jsonString = String(data: rhs, encoding: .utf8) ?? "{}"
            return "(\(lhs.queryFragment) || \(bind: jsonString)::jsonb)"
        }
    }
}

extension JSONB.AdditionalOperators {

    public enum Delete {

        public struct Key<LHS: QueryExpression>: QueryExpression {
            public typealias QueryValue = Data

            let jsonb: LHS
            let key: String

            public var queryFragment: QueryFragment {
                "(\(jsonb.queryFragment) - \(bind: key))"
            }
        }

        public struct Keys<LHS: QueryExpression>: QueryExpression {
            public typealias QueryValue = Data

            let jsonb: LHS
            let keys: [String]

            public var queryFragment: QueryFragment {
                var arrayFragment: QueryFragment = "ARRAY["
                for (index, key) in keys.enumerated() {
                    if index > 0 {
                        arrayFragment.append(", ")
                    }
                    arrayFragment.append("\(bind: key)")
                }
                arrayFragment.append("]")
                return "(\(jsonb.queryFragment) - \(arrayFragment))"
            }
        }

        public struct Index<LHS: QueryExpression>: QueryExpression {
            public typealias QueryValue = Data

            let jsonb: LHS
            let index: Int

            public var queryFragment: QueryFragment {
                "(\(jsonb.queryFragment) - \(index))"
            }
        }

        public struct Path<LHS: QueryExpression>: QueryExpression {
            public typealias QueryValue = Data

            let jsonb: LHS
            let path: [String]

            public var queryFragment: QueryFragment {
                "(\(jsonb.queryFragment) #- \(JSONB.TextPath(path).queryFragment))"
            }
        }
    }

    public enum TypedDelete {

        public struct Key<LHS: QueryExpression, Value: _JSONBRepresentationProtocol>:
            QueryExpression
        {
            public typealias QueryValue = Value

            let jsonb: LHS
            let key: String

            public var queryFragment: QueryFragment {
                "(\(jsonb.queryFragment) - \(bind: key))"
            }
        }

        public struct Keys<LHS: QueryExpression, Value: _JSONBRepresentationProtocol>:
            QueryExpression
        {
            public typealias QueryValue = Value

            let jsonb: LHS
            let keys: [String]

            public var queryFragment: QueryFragment {
                var arrayFragment: QueryFragment = "ARRAY["
                for (index, key) in keys.enumerated() {
                    if index > 0 {
                        arrayFragment.append(", ")
                    }
                    arrayFragment.append("\(bind: key)")
                }
                arrayFragment.append("]")
                return "(\(jsonb.queryFragment) - \(arrayFragment))"
            }
        }

        public struct Index<LHS: QueryExpression, Value: _JSONBRepresentationProtocol>:
            QueryExpression
        {
            public typealias QueryValue = Value

            let jsonb: LHS
            let index: Int

            public var queryFragment: QueryFragment {
                "(\(jsonb.queryFragment) - \(index))"
            }
        }

        public struct Path<LHS: QueryExpression, Value: _JSONBRepresentationProtocol>:
            QueryExpression
        {
            public typealias QueryValue = Value

            let jsonb: LHS
            let path: [String]

            public var queryFragment: QueryFragment {
                "(\(jsonb.queryFragment) #- \(JSONB.TextPath(path).queryFragment))"
            }
        }
    }
}

extension JSONB.AdditionalOperators {

    public struct PathExists<LHS: QueryExpression>: QueryExpression {
        public typealias QueryValue = Bool

        let jsonb: LHS
        let path: String

        public var queryFragment: QueryFragment {
            "(\(jsonb.queryFragment) @? \(bind: path))"
        }
    }

    public struct PathMatch<LHS: QueryExpression>: QueryExpression {
        public typealias QueryValue = Bool

        let jsonb: LHS
        let path: String

        public var queryFragment: QueryFragment {
            "(\(jsonb.queryFragment) @@ \(bind: path))"
        }
    }
}

extension TableColumn where Value: _JSONBColumnValue {

    public func jsonPathExists(_ path: String) -> some QueryExpression<Bool> {
        JSONB.AdditionalOperators.PathExists(jsonb: self, path: path)
    }

    public func jsonPathMatch(_ path: String) -> some QueryExpression<Bool> {
        JSONB.AdditionalOperators.PathMatch(jsonb: self, path: path)
    }
}
