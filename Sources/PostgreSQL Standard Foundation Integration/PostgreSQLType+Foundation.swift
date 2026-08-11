import Foundation
import PostgreSQL_Standard

extension Foundation.Date: PostgreSQLType {
    public static var typeName: String { "TIMESTAMP" }
}

extension Foundation.UUID: PostgreSQLType {
    public static var typeName: String { "UUID" }
}
