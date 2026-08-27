import Foundation
import Structured_Queries

extension QueryExpression where QueryValue == Double {

    public func sin() -> some QueryExpression<Double> {
        SQLQueryExpression(
            "sin(\(self.queryFragment))",
            as: Double.self
        )
    }

    public func cos() -> some QueryExpression<Double> {
        SQLQueryExpression(
            "cos(\(self.queryFragment))",
            as: Double.self
        )
    }

    public func tan() -> some QueryExpression<Double> {
        SQLQueryExpression(
            "tan(\(self.queryFragment))",
            as: Double.self
        )
    }

    public func cot() -> some QueryExpression<Double> {
        SQLQueryExpression(
            "cot(\(self.queryFragment))",
            as: Double.self
        )
    }

    public func asin() -> some QueryExpression<Double> {
        SQLQueryExpression(
            "asin(\(self.queryFragment))",
            as: Double.self
        )
    }

    public func acos() -> some QueryExpression<Double> {
        SQLQueryExpression(
            "acos(\(self.queryFragment))",
            as: Double.self
        )
    }

    public func atan() -> some QueryExpression<Double> {
        SQLQueryExpression(
            "atan(\(self.queryFragment))",
            as: Double.self
        )
    }

    public func atan2(_ x: Double) -> some QueryExpression<Double> {
        SQLQueryExpression(
            "atan2(\(self.queryFragment), \(bind: x))",
            as: Double.self
        )
    }

    public func atan2(_ x: some QueryExpression<Double>) -> some QueryExpression<Double> {
        SQLQueryExpression(
            "atan2(\(self.queryFragment), \(x.queryFragment))",
            as: Double.self
        )
    }

    public func acot() -> some QueryExpression<Double> {
        SQLQueryExpression(
            "acot(\(self.queryFragment))",
            as: Double.self
        )
    }

    public func sinh() -> some QueryExpression<Double> {
        SQLQueryExpression(
            "sinh(\(self.queryFragment))",
            as: Double.self
        )
    }

    public func cosh() -> some QueryExpression<Double> {
        SQLQueryExpression(
            "cosh(\(self.queryFragment))",
            as: Double.self
        )
    }

    public func tanh() -> some QueryExpression<Double> {
        SQLQueryExpression(
            "tanh(\(self.queryFragment))",
            as: Double.self
        )
    }

    public func coth() -> some QueryExpression<Double> {
        SQLQueryExpression(
            "coth(\(self.queryFragment))",
            as: Double.self
        )
    }

    public func asinh() -> some QueryExpression<Double> {
        SQLQueryExpression(
            "asinh(\(self.queryFragment))",
            as: Double.self
        )
    }

    public func acosh() -> some QueryExpression<Double> {
        SQLQueryExpression(
            "acosh(\(self.queryFragment))",
            as: Double.self
        )
    }

    public func atanh() -> some QueryExpression<Double> {
        SQLQueryExpression(
            "atanh(\(self.queryFragment))",
            as: Double.self
        )
    }

    public func acoth() -> some QueryExpression<Double> {
        SQLQueryExpression(
            "acoth(\(self.queryFragment))",
            as: Double.self
        )
    }
}

extension QueryExpression where QueryValue == Double {

    public func sec() -> some QueryExpression<Double> {
        SQLQueryExpression(
            "sec(\(self.queryFragment))",
            as: Double.self
        )
    }

    public func csc() -> some QueryExpression<Double> {
        SQLQueryExpression(
            "csc(\(self.queryFragment))",
            as: Double.self
        )
    }

    public func asec() -> some QueryExpression<Double> {
        SQLQueryExpression(
            "asec(\(self.queryFragment))",
            as: Double.self
        )
    }

    public func acsc() -> some QueryExpression<Double> {
        SQLQueryExpression(
            "acsc(\(self.queryFragment))",
            as: Double.self
        )
    }
}
