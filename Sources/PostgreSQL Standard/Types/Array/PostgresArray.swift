import Byte
import Foundation
import Structured_Queries
import Structured_Queries_Foundation_Integration

extension Array: QueryBindable, QueryExpression where Element: QueryBindable {
    public typealias QueryValue = [Element]

    public var queryBinding: QueryBinding {

        if Element.self == UInt8.self {

            return .blob((self as! [UInt8]).map(Byte.init))
        }

        switch Element.self {
        case is Bool.Type:

            return .boolArray(self as! [Bool])

        case is String.Type:

            return .stringArray(self as! [String])

        case is Int.Type:

            return .intArray(self as! [Int])

        case is Int16.Type:

            return .int16Array(self as! [Int16])

        case is Int32.Type:

            return .int32Array(self as! [Int32])

        case is Int64.Type:

            return .int64Array(self as! [Int64])

        case is Float.Type:

            return .floatArray(self as! [Float])

        case is Double.Type:

            return .doubleArray(self as! [Double])

        case is UUID.Type:

            return .uuidArray((self as! [UUID]).map(QueryBinding.UUID.init))

        case is Date.Type:

            return .dateArray((self as! [Date]).map(\.instant))

        default:

            return .genericArray(self.map { $0.queryBinding })
        }
    }
}

extension Array: _OptionalPromotable where Element: QueryDecodable {}

extension Array: QueryDecodable where Element: QueryDecodable {

    public init(decoder: inout some QueryDecoder) throws {

        if Element.self == UInt8.self {
            guard let result = try decoder.decode([Byte].self)
            else { throw QueryDecodingError.missingRequiredColumn }

            self = result.map(\.underlying) as! [Element]
            return
        }

        throw ArrayDecodingNotImplementedError()
    }
}

private struct ArrayDecodingNotImplementedError: Swift.Error {}

extension Array: @retroactive QueryRepresentable where Element: QueryDecodable {
    public init(queryOutput: [Element]) {
        self = queryOutput
    }

    public var queryOutput: [Element] {
        self
    }
}

public enum PostgresArrayDocumentation {}
