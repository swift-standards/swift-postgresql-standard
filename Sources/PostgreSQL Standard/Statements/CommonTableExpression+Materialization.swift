import Structured_Queries

extension CTE.Builder {

    public static func buildExpression<CTETable: Table, Base: PartialSelectStatement<CTETable>>(
        _ expression: MaterializedSelect<Base>
    ) -> CTE.Clause {
        CTE.Clause(
            tableName: "\(CTETable.self)",
            select: expression.base.query,
            materialization: expression.materialization
        )
    }
}
