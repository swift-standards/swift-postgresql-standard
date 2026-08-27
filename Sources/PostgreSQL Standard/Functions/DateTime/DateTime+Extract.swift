public import Foundation
public import Structured_Queries

public struct DateField<ReturnType: QueryBindable> {
    let sqlName: String

    private init(_ sqlName: String) {
        self.sqlName = sqlName
    }
}

extension DateField where ReturnType == Int {

    public static var year: DateField<Int> { DateField("YEAR") }

    public static var month: DateField<Int> { DateField("MONTH") }

    public static var day: DateField<Int> { DateField("DAY") }

    public static var hour: DateField<Int> { DateField("HOUR") }

    public static var minute: DateField<Int> { DateField("MINUTE") }

    public static var dow: DateField<Int> { DateField("DOW") }

    public static var doy: DateField<Int> { DateField("DOY") }
}

extension DateField where ReturnType == Double {

    public static var epoch: DateField<Double> { DateField("EPOCH") }

    public static var second: DateField<Double> { DateField("SECOND") }
}

extension QueryExpression where QueryValue == Date {

    public func extract<T>(_ field: DateField<T>) -> some QueryExpression<T> {
        SQLQueryExpression(
            "EXTRACT(\(raw: field.sqlName) FROM \(self.queryFragment))",
            as: T.self
        )
    }
}
