public import Foundation
import Structured_Queries

extension JSONB.Processing {

    public enum Path {}
}

extension JSONB.Processing.Path {

    public struct ExtractPath<LHS: QueryExpression>: QueryExpression {
        public typealias QueryValue = Foundation.Data

        let jsonb: LHS
        let path: [String]
        let format: Format

        enum Format {
            case json
            case jsonb

            var functionName: String {
                switch self {
                case .json: return "json_extract_path"
                case .jsonb: return "jsonb_extract_path"
                }
            }
        }

        public var queryFragment: QueryFragment {
            var fragment: QueryFragment = "\(raw: format.functionName)(\(jsonb.queryFragment)"
            for pathElement in path {
                fragment.append(", \(bind: pathElement)")
            }
            fragment.append(")")
            return fragment
        }
    }

    public struct ExtractPathText<LHS: QueryExpression>: QueryExpression {
        public typealias QueryValue = String?

        let jsonb: LHS
        let path: [String]
        let format: Format

        enum Format {
            case json
            case jsonb

            var functionName: String {
                switch self {
                case .json: return "json_extract_path_text"
                case .jsonb: return "jsonb_extract_path_text"
                }
            }
        }

        public var queryFragment: QueryFragment {
            var fragment: QueryFragment = "\(raw: format.functionName)(\(jsonb.queryFragment)"
            for pathElement in path {
                fragment.append(", \(bind: pathElement)")
            }
            fragment.append(")")
            return fragment
        }
    }

    public struct PathExists<LHS: QueryExpression>: QueryExpression {
        public typealias QueryValue = Bool

        let jsonb: LHS
        let path: String

        public var queryFragment: QueryFragment {
            "jsonb_path_exists(\(jsonb.queryFragment), \(bind: path))"
        }
    }

    public struct PathQuery<LHS: QueryExpression>: QueryExpression {
        public typealias QueryValue = Data

        let jsonb: LHS
        let path: String

        public var queryFragment: QueryFragment {
            "jsonb_path_query(\(jsonb.queryFragment), \(bind: path))"
        }
    }
}
