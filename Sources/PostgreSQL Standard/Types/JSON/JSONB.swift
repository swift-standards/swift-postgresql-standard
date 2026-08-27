import Byte
public import Foundation
import Structured_Queries

public protocol _JSONBRepresentationProtocol: QueryRepresentable {
    associatedtype UnderlyingType: Codable
}

public struct _JSONBRepresentation<QueryOutput: Codable>: _JSONBRepresentationProtocol {
    public typealias UnderlyingType = QueryOutput

    public var queryOutput: QueryOutput

    public init(queryOutput: QueryOutput) {
        self.queryOutput = queryOutput
    }
}

extension Decodable where Self: Encodable {

    public typealias JSONB = _JSONBRepresentation<Self>
}

extension Optional where Wrapped: Codable {
    @_documentation(visibility: private)
    public typealias JSONB = _JSONBRepresentation<Wrapped>?
}

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

extension _JSONBRepresentation: Equatable where QueryOutput: Equatable {}
extension _JSONBRepresentation: Sendable where QueryOutput: Sendable {}

private let jsonDecoder: JSONDecoder = {
    var decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .custom {
        let timestamp = try $0.singleValueContainer().decode(String.self)

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
        encoder.outputFormatting = [.sortedKeys]
    #endif
    return encoder
}()

private let jsonbTimestampFractional = Date.ISO8601FormatStyle()
    .year().month().day()
    .dateTimeSeparator(.space)
    .time(includingFractionalSeconds: true)

private let jsonbTimestampWhole = Date.ISO8601FormatStyle()
    .year().month().day()
    .dateTimeSeparator(.space)
    .time(includingFractionalSeconds: false)
