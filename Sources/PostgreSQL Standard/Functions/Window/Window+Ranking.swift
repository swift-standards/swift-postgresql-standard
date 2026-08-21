import Foundation
import Structured_Queries_Primitives

public func rowNumber() -> Window.Function<Int> {
    Window.Function(functionName: "ROW_NUMBER", arguments: [])
}

public func rank() -> Window.Function<Int> {
    Window.Function(functionName: "RANK", arguments: [])
}

public func denseRank() -> Window.Function<Int> {
    Window.Function(functionName: "DENSE_RANK", arguments: [])
}

public func percentRank() -> Window.Function<Double> {
    Window.Function(functionName: "PERCENT_RANK", arguments: [])
}

public func cumeDist() -> Window.Function<Double> {
    Window.Function(functionName: "CUME_DIST", arguments: [])
}

public func ntile(_ buckets: Int) -> Window.Function<Int> {
    precondition(buckets > 0, "ntile buckets must be positive")
    return Window.Function(
        functionName: "NTILE",
        arguments: [QueryFragment(stringLiteral: "\(buckets)")]
    )
}

extension Window {

    public static func rowNumber() -> Function<Int> {
        PostgreSQL_Standard.rowNumber()
    }

    public static func rank() -> Function<Int> {
        PostgreSQL_Standard.rank()
    }

    public static func denseRank() -> Function<Int> {
        PostgreSQL_Standard.denseRank()
    }

    public static func percentRank() -> Function<Double> {
        PostgreSQL_Standard.percentRank()
    }

    public static func cumeDist() -> Function<Double> {
        PostgreSQL_Standard.cumeDist()
    }

    public static func ntile(_ buckets: Int) -> Function<Int> {
        PostgreSQL_Standard.ntile(buckets)
    }
}
