import PostgreSQL_Standard
import Byte_Primitives
public import Foundation
import Structured_Queries_Primitives

/// Protocol to identify JSONB representation types
/// Used for operator extension constraints
public protocol _JSONBRepresentationProtocol: QueryRepresentable {
    associatedtype UnderlyingType: Codable
}

/// A type representing PostgreSQL JSONB storage for Codable types.
///
/// This type mirrors the upstream `_CodableJSONRepresentation` pattern but uses
/// PostgreSQL's binary JSONB format instead of text JSON.
///
/// ```swift
/// @Table("posts")
/// struct Post {
///     @Column(as: [String].JSONB.self)
///     var tags: [String]
///
///     @Column(as: [String: String].JSONB.self)
///     var metadata: [String: String]
/// }
/// ```
public struct _JSONBRepresentation<QueryOutput: Codable>: _JSONBRepresentationProtocol {
    public typealias UnderlyingType = QueryOutput

    public var queryOutput: QueryOutput

    public init(queryOutput: QueryOutput) {
        self.queryOutput = queryOutput
    }
}

// MARK: - Typealias Extensions

extension Decodable where Self: Encodable {
    /// A query expression representing PostgreSQL JSONB.
    ///
    /// JSONB is PostgreSQL's binary JSON format that provides better performance
    /// and indexing capabilities compared to regular JSON text.
    ///
    /// ```swift
    /// @Table
    /// struct SubscriptionPlan {
    ///   @Column(as: [String].JSONB.self)
    ///   var features: [String]
    ///
    ///   @Column(as: [String: String].JSONB.self)
    ///   var restrictions: [String: String]
    /// }
    /// ```
    public typealias JSONB = _JSONBRepresentation<Self>
}

extension Optional where Wrapped: Codable {
    @_documentation(visibility: private)
    public typealias JSONB = _JSONBRepresentation<Wrapped>?
}

// MARK: - QueryBindable

extension _JSONBRepresentation: QueryBindable {
    public var queryBinding: QueryBinding {
        do {
            let jsonData = try jsonEncoder.encode(queryOutput)
            return .jsonb(jsonData.map(Byte.init))
        } catch {
            return .invalid(error)
        }
    }
}

// MARK: - QueryDecodable

extension _JSONBRepresentation: QueryDecodable {
    public init(decoder: inout some QueryDecoder) throws {
        self.init(
            queryOutput: try jsonDecoder.decode(
                QueryOutput.self,
                from: Foundation.Data(String(decoder: &decoder).utf8)
            )
        )
    }
}

// MARK: - Equatable & Sendable

extension _JSONBRepresentation: Equatable where QueryOutput: Equatable {}
extension _JSONBRepresentation: Sendable where QueryOutput: Sendable {}

// MARK: - JSON Encoder/Decoder

private let jsonDecoder: JSONDecoder = {
    var decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .custom {
        let timestamp = try $0.singleValueContainer().decode(String.self)
        // The fractional part is the only optional element of the shape, and a `.`
        // appears nowhere else in it, so its presence selects the strategy outright.
        return try Date(
            timestamp,
            strategy: timestamp.contains(where: { $0 == "." })
                ? jsonbTimestampFractional
                : jsonbTimestampWhole
        )
    }
    return decoder
}()

private let jsonEncoder: JSONEncoder = {
    var encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .custom { date, encoder in
        var container = encoder.singleValueContainer()
        try container.encode(date.formatted(jsonbTimestampFractional))
    }
    #if DEBUG
        encoder.outputFormatting = [.sortedKeys]  // Remove prettyPrinted for SQL
    #endif
    return encoder
}()

// MARK: - JSONB Timestamp Representation

// `yyyy-MM-dd HH:mm:ss.SSS` in UTC — the shape this package has always written
// into JSONB documents. It was supplied by `Date.iso8601String` in the L1 core
// until the Foundation drain deleted it; re-homing it here keeps the stored
// representation byte-identical.
//
// Deliberately *not* routed through `swift-rfc-3339`: RFC 3339 requires a `T`
// (or `t`) date/time separator and a mandatory `time-offset`, so that package
// can neither emit nor parse this shape. Adopting it would silently rewrite the
// timestamps in every existing JSONB column.

private let jsonbTimestampFractional = Date.ISO8601FormatStyle()
    .year().month().day()
    .dateTimeSeparator(.space)
    .time(includingFractionalSeconds: true)

private let jsonbTimestampWhole = Date.ISO8601FormatStyle()
    .year().month().day()
    .dateTimeSeparator(.space)
    .time(includingFractionalSeconds: false)
