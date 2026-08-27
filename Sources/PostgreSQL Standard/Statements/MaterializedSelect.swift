import Structured_Queries

public struct MaterializedSelect<Base: PartialSelectStatement>: PartialSelectStatement {
    public typealias QueryValue = Base.QueryValue
    public typealias From = Base.From
    public typealias Joins = Base.Joins

    let base: Base
    let materialization: CTE.Clause.MaterializationHint

    public var query: QueryFragment { base.query }
}

extension PartialSelectStatement {

    public func materialized() -> MaterializedSelect<Self> {
        MaterializedSelect(base: self, materialization: .materialized)
    }

    public func notMaterialized() -> MaterializedSelect<Self> {
        MaterializedSelect(base: self, materialization: .notMaterialized)
    }
}
