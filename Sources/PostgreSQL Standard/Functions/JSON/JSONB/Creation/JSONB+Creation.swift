public import Foundation
import Structured_Queries

extension JSONB {

    public enum Creation {}
}

extension JSONB.Creation {

    public static func arrayToJson<T: QueryExpression>(_ array: T) -> some QueryExpression<Data> {
        QueryFunction("array_to_json", array)
    }

    public static func rowToJson<T: Table>(_ table: T.Type) -> some QueryExpression<Data> {
        var fragment: QueryFragment = "row_to_json("
        if let schemaName = T.schemaName {
            fragment.append("\(quote: schemaName).")
        }
        fragment.append("\(quote: T.tableName).*)")
        return SQLQueryExpression(fragment, as: Foundation.Data.self)
    }

    public static func object(keys: [String], values: [String]) -> some QueryExpression<Data> {
        JSONObjectFromArrays(keys: keys, values: values)
    }

    public static func buildArray(_ values: any QueryExpression...) -> some QueryExpression<Data> {
        JSONBuildArray(values: values, format: .jsonb)
    }

    public static func buildJsonArray(
        _ values: any QueryExpression...
    ) -> some QueryExpression<
        Data
    > {
        JSONBuildArray(values: values, format: .json)
    }
}

extension JSONB.Creation {
    fileprivate struct JSONBuildArray: QueryExpression {
        let values: [any QueryExpression]
        let format: JSONFormat
    }

    fileprivate struct JSONObjectFromArrays: QueryExpression {
        let keys: [String]
        let values: [String]
    }
}

extension JSONB.Creation.JSONBuildArray {
    typealias QueryValue = Data

    enum JSONFormat: String {
        case json
        case jsonb
    }

    var queryFragment: QueryFragment {
        var fragment: QueryFragment = "\(raw: format.rawValue)_build_array("

        for (index, value) in values.enumerated() {
            if index > 0 {
                fragment.append(", ")
            }
            fragment.append(value.queryFragment)
        }

        fragment.append(")")
        return fragment
    }
}

extension JSONB.Creation.JSONObjectFromArrays {
    typealias QueryValue = Data

    var queryFragment: QueryFragment {
        let keysArray = "'{" + keys.joined(separator: ",") + "}'"
        let valuesArray = "'{" + values.joined(separator: ",") + "}'"
        return "json_object(\(raw: keysArray), \(raw: valuesArray))"
    }
}

extension QueryExpression {

    public func toJsonb() -> some QueryExpression<Data> {
        QueryFunction("to_jsonb", self)
    }

    public func toJson() -> some QueryExpression<Data> {
        QueryFunction("to_json", self)
    }
}
