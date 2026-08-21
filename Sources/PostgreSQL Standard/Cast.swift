public import Foundation
import Structured_Queries_Primitives

extension QueryExpression where QueryValue: QueryBindable {

    public func cast<Other: PostgreSQLType>(
        as _: Other.Type = Other.self
    ) -> some QueryExpression<Other> {
        Cast(base: self)
    }
}

extension QueryExpression where QueryValue: QueryBindable & _OptionalProtocol {

    public func cast<Other: _OptionalPromotable & PostgreSQLType>(
        as _: Other.Type = Other.self
    ) -> some QueryExpression<Other._Optionalized>
    where Other._Optionalized: PostgreSQLType {
        Cast(base: self)
    }
}

extension QueryExpression where QueryValue == Int {

    public func cast() -> some QueryExpression<Double> {
        cast(as: Double.self)
    }
}

extension QueryExpression where QueryValue == Int? {

    public func cast() -> some QueryExpression<Double?> {
        cast(as: Double.self)
    }
}

public protocol PostgreSQLType: QueryBindable {
    static var typeName: String { get }
}

extension PostgreSQLType where Self: BinaryInteger {
    public static var typeName: String { "INTEGER" }
}

extension Int: PostgreSQLType {}
extension Int8: PostgreSQLType {
    public static var typeName: String { "SMALLINT" }
}
extension Int16: PostgreSQLType {
    public static var typeName: String { "SMALLINT" }
}
extension Int32: PostgreSQLType {
    public static var typeName: String { "INTEGER" }
}
extension Int64: PostgreSQLType {
    public static var typeName: String { "BIGINT" }
}

extension UInt8: PostgreSQLType {
    public static var typeName: String { "SMALLINT" }
}
extension UInt16: PostgreSQLType {
    public static var typeName: String { "INTEGER" }
}
extension UInt32: PostgreSQLType {
    public static var typeName: String { "BIGINT" }
}

extension PostgreSQLType where Self: FloatingPoint {
    public static var typeName: String { "REAL" }
}

extension Double: PostgreSQLType {
    public static var typeName: String { "DOUBLE PRECISION" }
}
extension Float: PostgreSQLType {}

extension Bool: PostgreSQLType {
    public static var typeName: String { "BOOLEAN" }
}

extension String: PostgreSQLType {
    public static var typeName: String { "TEXT" }
}

extension [UInt8]: PostgreSQLType {
    public static var typeName: String { "BYTEA" }
}

extension Foundation.Date: PostgreSQLType {
    public static var typeName: String { "TIMESTAMP" }
}

extension UUID: PostgreSQLType {
    public static var typeName: String { "UUID" }
}

extension Optional: PostgreSQLType where Wrapped: PostgreSQLType {
    public static var typeName: String { Wrapped.typeName }
}

extension RawRepresentable where RawValue: PostgreSQLType {
    public static var typeName: String { RawValue.typeName }
}

private struct Cast<QueryValue: PostgreSQLType, Base: QueryExpression>: QueryExpression {
    let base: Base
    var queryFragment: QueryFragment {
        "CAST(\(base.queryFragment) AS \(raw: QueryValue.typeName))"
    }
}
