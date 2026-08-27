import Foundation
import Structured_Queries

extension QueryExpression where QueryValue: Numeric & QueryBindable {

    public func power(_ exponent: QueryValue) -> some QueryExpression<Double> {
        SQLQueryExpression(
            "power(\(self.queryFragment), \(bind: exponent))",
            as: Double.self
        )
    }

    public func power(_ exponent: some QueryExpression<QueryValue>) -> some QueryExpression<Double>
    {
        SQLQueryExpression(
            "power(\(self.queryFragment), \(exponent.queryFragment))",
            as: Double.self
        )
    }

    public func sqrt() -> some QueryExpression<Double> {
        SQLQueryExpression(
            "sqrt(\(self.queryFragment))",
            as: Double.self
        )
    }

    public func cbrt() -> some QueryExpression<Double> {
        SQLQueryExpression(
            "cbrt(\(self.queryFragment))",
            as: Double.self
        )
    }
}

extension QueryExpression where QueryValue == Double {

    public func exp() -> some QueryExpression<Double> {
        SQLQueryExpression(
            "exp(\(self.queryFragment))",
            as: Double.self
        )
    }

    public func ln() -> some QueryExpression<Double> {
        SQLQueryExpression(
            "ln(\(self.queryFragment))",
            as: Double.self
        )
    }

    public func log10() -> some QueryExpression<Double> {
        SQLQueryExpression(
            "log(\(self.queryFragment))",
            as: Double.self
        )
    }

    public func log(base: Double) -> some QueryExpression<Double> {
        SQLQueryExpression(
            "log(\(bind: base), \(self.queryFragment))",
            as: Double.self
        )
    }

    public func log2() -> some QueryExpression<Double> {
        SQLQueryExpression(
            "log2(\(self.queryFragment))",
            as: Double.self
        )
    }
}

extension QueryExpression where QueryValue == Double {

    public func degrees() -> some QueryExpression<Double> {
        SQLQueryExpression(
            "degrees(\(self.queryFragment))",
            as: Double.self
        )
    }

    public func radians() -> some QueryExpression<Double> {
        SQLQueryExpression(
            "radians(\(self.queryFragment))",
            as: Double.self
        )
    }
}

public func pi() -> some QueryExpression<Double> {
    SQLQueryExpression("pi()", as: Double.self)
}
