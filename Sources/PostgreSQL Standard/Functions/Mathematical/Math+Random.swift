import Foundation
import Structured_Queries_Primitives

extension Math {

    public static func random() -> some QueryExpression<Double> {
        SQLQueryExpression("random()", as: Double.self)
    }

    public static func setseed(_ seed: Double) -> some QueryExpression<Void> {
        SQLQueryExpression("setseed(\(bind: seed))", as: Void.self)
    }
}

public func random() -> some QueryExpression<Double> {
    Math.random()
}

public func setseed(_ seed: Double) -> some QueryExpression<Void> {
    Math.setseed(seed)
}
