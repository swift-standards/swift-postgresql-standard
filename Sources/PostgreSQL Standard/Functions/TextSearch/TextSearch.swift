import Foundation
import Structured_Queries

public enum TextSearch {}

extension TextSearch {

    public struct Vector: Sendable, Hashable, Codable {

        public let value: String

        public init(value: String) {
            self.value = value
        }
    }
}

extension TextSearch.Vector: QueryBindable {
    public var queryBinding: QueryBinding {

        .text(value)
    }
}

extension TextSearch.Vector: QueryDecodable {
    @inlinable

    public init(decoder: inout some QueryDecoder) throws {
        guard let result = try decoder.decode(String.self)
        else { throw QueryDecodingError.missingRequiredColumn }
        self.init(value: result)
    }
}

extension TextSearch.Vector: CustomStringConvertible {
    public var description: String {
        value
    }
}

extension TextSearch.Vector: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value: value)
    }
}

@available(*, deprecated, renamed: "TextSearch.Vector")
public typealias TSVector = TextSearch.Vector

extension TextSearch {

    public enum Weight: String, Sendable {

        case A

        case B

        case C

        case D
    }
}

extension TextSearch {

    public struct WordRange: Sendable, Equatable {
        public let min: Int
        public let max: Int

        public init?(min: Int, max: Int) {
            guard min > 0, max > 0, min < max else { return nil }
            self.min = min
            self.max = max
        }
    }

    public struct RankNormalization: OptionSet, Sendable, ExpressibleByIntegerLiteral {

        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public init(integerLiteral value: Int) {
            self.rawValue = value
        }
    }
}

extension TextSearch.WordRange {

    public static func upTo(_ max: Int) -> TextSearch.WordRange? {
        TextSearch.WordRange(min: 15, max: max)
    }

    public static let short = TextSearch.WordRange(min: 3, max: 10)!

    public static let medium = TextSearch.WordRange(min: 10, max: 25)!

    public static let long = TextSearch.WordRange(min: 20, max: 50)!
}

extension TextSearch.RankNormalization {

    public static let none = TextSearch.RankNormalization([])

    public static let divideByLogLength = TextSearch.RankNormalization(rawValue: 1)

    public static let divideByLength = TextSearch.RankNormalization(rawValue: 2)

    public static let divideByMeanHarmonicDistance = TextSearch.RankNormalization(rawValue: 4)

    public static let divideByUniqueWordCount = TextSearch.RankNormalization(rawValue: 8)

    public static let divideByLogUniqueWords = TextSearch.RankNormalization(rawValue: 16)

    public static let divideByRankPlusOne = TextSearch.RankNormalization(rawValue: 32)
}

public protocol FullTextSearchable: Table {

    static var searchVectorColumn: String { get }
}

extension FullTextSearchable {

    public static var searchVectorColumn: String { "searchVector" }
}

extension Optional: FullTextSearchable where Wrapped: FullTextSearchable {
    public static var searchVectorColumn: String { Wrapped.searchVectorColumn }
}

extension TableAlias: FullTextSearchable where Base: FullTextSearchable {
    public static var searchVectorColumn: String { Base.searchVectorColumn }
}
