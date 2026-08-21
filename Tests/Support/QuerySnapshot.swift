import Structured_Queries_Primitives
import Test_Primitives_Core
import Test_Snapshot_Primitives

extension Test_Primitives_Core.Test.Snapshot.Strategy where Value: Statement, Format == String {

    public static var sql: Self {
        Test_Primitives_Core.Test.Snapshot.Strategy<String, String>.lines.pullback(
            \.query.debugDescription
        )
    }
}

extension Test_Primitives_Core.Test.Snapshot.Strategy
where Value: QueryExpression, Format == String {

    public static var sql: Self {
        Test_Primitives_Core.Test.Snapshot.Strategy<String, String>.lines.pullback(
            \.queryFragment.debugDescription
        )
    }
}
