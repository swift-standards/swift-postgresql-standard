public import Foundation
public import Structured_Queries_Primitives

extension Date {

    public static var currentTimestamp: some QueryExpression<Date> {
        SQLQueryExpression("CURRENT_TIMESTAMP", as: Date.self)
    }

    public static var currentDate: some QueryExpression<Date> {
        SQLQueryExpression("CURRENT_DATE", as: Date.self)
    }
}
