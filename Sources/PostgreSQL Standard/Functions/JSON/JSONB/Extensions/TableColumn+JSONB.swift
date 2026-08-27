public import Foundation
public import Structured_Queries

public protocol _JSONBColumnValue {}

extension _JSONBRepresentation: _JSONBColumnValue {}
extension Data: _JSONBColumnValue {}

extension TableColumn where Value: _JSONBColumnValue {

    public func contains<T: Encodable>(_ value: T) -> some QueryExpression<Bool> {
        JSONB.AdditionalOperators.Contains(lhs: self, rhs: value)
    }

    public func isContained<T: Encodable>(by value: T) -> some QueryExpression<Bool> {
        JSONB.AdditionalOperators.ContainedBy(lhs: self, rhs: value)
    }

    public func hasKey(_ key: String) -> some QueryExpression<Bool> {
        JSONB.AdditionalOperators.Keys.Exists(jsonb: self, key: key)
    }

    public func hasAny(of keys: [String]) -> some QueryExpression<Bool> {
        JSONB.AdditionalOperators.Keys.AnyExist(jsonb: self, keys: keys)
    }

    public func hasAll(of keys: [String]) -> some QueryExpression<Bool> {
        JSONB.AdditionalOperators.Keys.AllExist(jsonb: self, keys: keys)
    }

    public func field(_ key: String) -> some QueryExpression<Data> {
        JSONB.Operators.Field(jsonb: self, key: key)
    }

    public func fieldAsText(_ key: String) -> some QueryExpression<String?> {
        JSONB.Operators.FieldText(jsonb: self, key: key)
    }

    public func element(at index: Int) -> some QueryExpression<Data> {
        JSONB.Operators.Index(jsonb: self, index: index)
    }

    public func elementAsText(at index: Int) -> some QueryExpression<String?> {
        JSONB.Operators.IndexText(jsonb: self, index: index)
    }

    public func value(at path: [String]) -> some QueryExpression<Data> {
        JSONB.Operators.Path(jsonb: self, path: path)
    }

    public func valueAsText(at path: [String]) -> some QueryExpression<String?> {
        JSONB.Operators.PathText(jsonb: self, path: path)
    }

    public func arrayElements() -> some QueryExpression<Data> {
        JSONB.Processing.SetReturning.ArrayElements(jsonb: self, format: .jsonb)
    }

    public func arrayElementsText() -> some QueryExpression<String> {
        JSONB.Processing.SetReturning.ArrayElementsText(jsonb: self, format: .jsonb)
    }

    public func each() -> some QueryExpression<(String, Data)> {
        JSONB.Processing.SetReturning.Each(jsonb: self, format: .jsonb)
    }

    public func eachText() -> some QueryExpression<(String, String)> {
        JSONB.Processing.SetReturning.EachText(jsonb: self, format: .jsonb)
    }

    public func objectKeys() -> some QueryExpression<String> {
        JSONB.Processing.SetReturning.ObjectKeys(jsonb: self, format: .jsonb)
    }

    public func extractPath(_ path: [String]) -> some QueryExpression<Data> {
        JSONB.Processing.Path.ExtractPath(jsonb: self, path: path, format: .jsonb)
    }

    public func extractPathText(_ path: [String]) -> some QueryExpression<String?> {
        JSONB.Processing.Path.ExtractPathText(jsonb: self, path: path, format: .jsonb)
    }

    public func pathExists(_ path: String) -> some QueryExpression<Bool> {
        JSONB.Processing.Path.PathExists(jsonb: self, path: path)
    }

    public func pathQuery(_ path: String) -> some QueryExpression<Data> {
        JSONB.Processing.Path.PathQuery(jsonb: self, path: path)
    }

}

extension TableColumn where Value: _JSONBRepresentationProtocol {

    public func concat<T: Encodable>(_ value: T) -> some QueryExpression<Value> {
        JSONB.AdditionalOperators.TypedConcat(lhs: self, rhs: value)
    }

    public func removing(_ key: String) -> some QueryExpression<Value> {
        JSONB.AdditionalOperators.TypedDelete.Key(jsonb: self, key: key)
    }

    public func removing(keys: [String]) -> some QueryExpression<Value> {
        JSONB.AdditionalOperators.TypedDelete.Keys(jsonb: self, keys: keys)
    }

    public func removing(at index: Int) -> some QueryExpression<Value> {
        JSONB.AdditionalOperators.TypedDelete.Index(jsonb: self, index: index)
    }

    public func removing(path: [String]) -> some QueryExpression<Value> {
        JSONB.AdditionalOperators.TypedDelete.Path(jsonb: self, path: path)
    }

    public func setting<T: Encodable>(
        _ path: [String],
        to value: T,
        createIfMissing: Bool = true
    ) -> some QueryExpression<Value> {
        JSONB.Processing.TypedSet(
            jsonb: self,
            path: path,
            value: value,
            createIfMissing: createIfMissing
        )
    }

    public func inserting<T: Encodable>(
        _ value: T,
        at path: [String],
        after: Bool = false
    ) -> some QueryExpression<Value> {
        JSONB.Processing.TypedInsert(jsonb: self, path: path, value: value, after: after)
    }

    public func strippingNulls() -> some QueryExpression<Value> {
        JSONB.Processing.TypedStripNulls(jsonb: self)
    }
}

extension TableColumn where Value == Data {

    public func concat<T: Encodable>(_ value: T) -> some QueryExpression<Data> {
        JSONB.AdditionalOperators.Concat(lhs: self, rhs: value)
    }

    public func removing(_ key: String) -> some QueryExpression<Data> {
        JSONB.AdditionalOperators.Delete.Key(jsonb: self, key: key)
    }

    public func removing(keys: [String]) -> some QueryExpression<Data> {
        JSONB.AdditionalOperators.Delete.Keys(jsonb: self, keys: keys)
    }

    public func removing(at index: Int) -> some QueryExpression<Data> {
        JSONB.AdditionalOperators.Delete.Index(jsonb: self, index: index)
    }

    public func removing(path: [String]) -> some QueryExpression<Data> {
        JSONB.AdditionalOperators.Delete.Path(jsonb: self, path: path)
    }
}
