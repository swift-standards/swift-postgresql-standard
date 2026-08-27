import Structured_Queries

extension PrimaryKeyedTable {

    public static func delete(_ row: Self) -> DeleteOf<Self> {
        delete()
            .where {
                $0.primaryKey.eq(PrimaryKey(queryOutput: row[keyPath: $0.primaryKey.keyPath]))
            }
    }
}
