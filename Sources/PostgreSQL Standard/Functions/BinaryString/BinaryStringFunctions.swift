import Foundation
import Structured_Queries

extension QueryExpression where QueryValue == [UInt8] {

    public func hex() -> some QueryExpression<String> {
        QueryFunction("hex", self)
    }
}
