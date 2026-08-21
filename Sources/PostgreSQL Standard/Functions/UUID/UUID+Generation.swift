public import Foundation
import Structured_Queries_Primitives

extension PostgreSQL.UUID {

    public static func random() -> some QueryExpression<Foundation.UUID> {
        SQLQueryExpression("gen_random_uuid()", as: Foundation.UUID.self)
    }

    public static func v4() -> some QueryExpression<Foundation.UUID> {
        SQLQueryExpression("uuidv4()", as: Foundation.UUID.self)
    }

    public static func timeOrdered() -> some QueryExpression<Foundation.UUID> {
        SQLQueryExpression("uuidv7()", as: Foundation.UUID.self)
    }

    public static func v7() -> some QueryExpression<Foundation.UUID> {
        SQLQueryExpression("uuidv7()", as: Foundation.UUID.self)
    }

    public static func timeOrdered(shift: String) -> some QueryExpression<Foundation.UUID> {
        SQLQueryExpression("uuidv7('\(raw: shift)'::interval)", as: Foundation.UUID.self)
    }
}

extension Foundation.UUID {

    public static var random: some QueryExpression<Foundation.UUID> {
        PostgreSQL.UUID.random()
    }

    public static var v4: some QueryExpression<Foundation.UUID> {
        PostgreSQL.UUID.v4()
    }

    public static var timeOrdered: some QueryExpression<Foundation.UUID> {
        PostgreSQL.UUID.timeOrdered()
    }

    public static var v7: some QueryExpression<Foundation.UUID> {
        PostgreSQL.UUID.v7()
    }

    public static func timeOrdered(shift: String) -> some QueryExpression<Foundation.UUID> {
        PostgreSQL.UUID.timeOrdered(shift: shift)
    }
}
