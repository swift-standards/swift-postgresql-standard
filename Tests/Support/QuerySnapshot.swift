import Structured_Queries
import Test_Core
import Test_Snapshot

extension Test_Core.Test.Snapshot.Strategy where Value: Statement, Format == String {

    public static var sql: Self {
        Test_Core.Test.Snapshot.Strategy<String, String>.lines.pullback(
            \.query.debugDescription
        )
    }
}

extension Test_Core.Test.Snapshot.Strategy
where Value: QueryExpression, Format == String {

    public static var sql: Self {
        Test_Core.Test.Snapshot.Strategy<String, String>.lines.pullback(
            \.queryFragment.debugDescription
        )
    }
}
