import Structured_Queries

extension PrimaryKeyedTable {

    public static func update(
        _ row: Self
    ) -> UpdateOf<Self> {
        update { updates in
            for column in TableColumns.writableColumns
            where !columns.primaryKey._names.contains(column.name) {
                func open<Root, Value>(_ column: some WritableTableColumnExpression<Root, Value>) {
                    updates.set(
                        column,

                        Value(queryOutput: (row as! Root)[keyPath: column.keyPath]).queryFragment
                    )
                }
                open(column)
            }
        }
        .where {
            $0.primaryKey.eq(PrimaryKey(queryOutput: row[keyPath: $0.primaryKey.keyPath]))
        }
    }
}
