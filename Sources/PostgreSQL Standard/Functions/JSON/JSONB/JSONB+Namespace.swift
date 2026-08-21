import Foundation
import Structured_Queries_Primitives

public enum JSONB {}

internal let jsonbEncoder: JSONEncoder = {
    var encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    encoder.outputFormatting = [.sortedKeys]
    return encoder
}()
