import Foundation
import Structured_Queries_Primitives

extension QueryExpression where QueryValue == [UInt8] {

    public func encodeHex() -> some QueryExpression<String> {
        SQLQueryExpression("ENCODE(\(self.queryFragment), 'hex')", as: String.self)
    }

    public func encode(_ format: String) -> some QueryExpression<String> {
        SQLQueryExpression("ENCODE(\(self.queryFragment), \(bind: format))", as: String.self)
    }
}

extension QueryExpression where QueryValue == String {

    public func decodeHex() -> some QueryExpression<[UInt8]> {
        SQLQueryExpression("DECODE(\(self.queryFragment), 'hex')", as: [UInt8].self)
    }
}
