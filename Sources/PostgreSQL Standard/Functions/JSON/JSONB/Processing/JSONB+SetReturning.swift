public import Foundation
public import Structured_Queries_Primitives

extension JSONB.Processing {

    public enum SetReturning {}
}

extension JSONB.Processing.SetReturning {

    public struct ArrayElements<LHS: QueryExpression>: QueryExpression {
        public typealias QueryValue = Data

        let jsonb: LHS
        let format: Format

        enum Format {
            case json
            case jsonb

            var functionName: String {
                switch self {
                case .json: return "json_array_elements"
                case .jsonb: return "jsonb_array_elements"
                }
            }
        }

        public var queryFragment: QueryFragment {
            "\(raw: format.functionName)(\(jsonb.queryFragment))"
        }
    }

    public struct ArrayElementsText<LHS: QueryExpression>: QueryExpression {
        public typealias QueryValue = String

        let jsonb: LHS
        let format: Format

        enum Format {
            case json
            case jsonb

            var functionName: String {
                switch self {
                case .json: return "json_array_elements_text"
                case .jsonb: return "jsonb_array_elements_text"
                }
            }
        }

        public var queryFragment: QueryFragment {
            "\(raw: format.functionName)(\(jsonb.queryFragment))"
        }
    }

    public struct Each<LHS: QueryExpression>: QueryExpression {
        public typealias QueryValue = (String, Data)

        let jsonb: LHS
        let format: Format

        enum Format {
            case json
            case jsonb

            var functionName: String {
                switch self {
                case .json: return "json_each"
                case .jsonb: return "jsonb_each"
                }
            }
        }

        public var queryFragment: QueryFragment {
            "\(raw: format.functionName)(\(jsonb.queryFragment))"
        }
    }

    public struct EachText<LHS: QueryExpression>: QueryExpression {
        public typealias QueryValue = (String, String)

        let jsonb: LHS
        let format: Format

        enum Format {
            case json
            case jsonb

            var functionName: String {
                switch self {
                case .json: return "json_each_text"
                case .jsonb: return "jsonb_each_text"
                }
            }
        }

        public var queryFragment: QueryFragment {
            "\(raw: format.functionName)(\(jsonb.queryFragment))"
        }
    }

    public struct ObjectKeys<LHS: QueryExpression>: QueryExpression {
        public typealias QueryValue = String

        let jsonb: LHS
        let format: Format

        enum Format {
            case json
            case jsonb

            var functionName: String {
                switch self {
                case .json: return "json_object_keys"
                case .jsonb: return "jsonb_object_keys"
                }
            }
        }

        public var queryFragment: QueryFragment {
            "\(raw: format.functionName)(\(jsonb.queryFragment))"
        }
    }
}
