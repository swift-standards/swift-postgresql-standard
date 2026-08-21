import Foundation

extension TableDraft {

    public static func insert(
        _ columns: (TableColumns) -> TableColumns = { $0 },
        @InsertValuesBuilder<Self> values: () -> [[QueryFragment]],
        onConflictDoUpdate updates: ((inout Updates<Self>, Excluded) -> Void)? = nil,
        @QueryFragmentBuilder<Bool>
        where updateFilter: (TableColumns) -> [QueryFragment] = { _ in [] }
    ) -> InsertOf<Self> {
        let (columnNames, processedValues) = nullPrimaryKeysDefaulted(values())

        return _insert(
            columnNames: columnNames,
            values: .values(processedValues),
            onConflict: { _ -> ()? in nil },
            where: [],
            doUpdate: updates,
            where: updateFilter(Self.columns)
        )
    }

    public static func insert(
        _ columns: (TableColumns) -> TableColumns = { $0 },
        @InsertValuesBuilder<Self> values: () -> [[QueryFragment]],
        onConflictDoUpdate updates: ((inout Updates<Self>) -> Void)?,
        @QueryFragmentBuilder<Bool>
        where updateFilter: (TableColumns) -> [QueryFragment] = { _ in [] }
    ) -> InsertOf<Self> {
        insert(
            columns,
            values: values,
            onConflictDoUpdate: updates.map { updates in { row, _ in updates(&row) } },
            where: updateFilter
        )
    }

    public static func insert<T1, each T2>(
        _ columns: (TableColumns) -> TableColumns = { $0 },
        @InsertValuesBuilder<Self> values: () -> [[QueryFragment]],
        onConflict conflictTargets: (TableColumns) -> (
            TableColumn<Self, T1>, repeat TableColumn<Self, each T2>
        ),
        @QueryFragmentBuilder<Bool>
        where targetFilter: (TableColumns) -> [QueryFragment] = { _ in [] },
        doUpdate updates: (inout Updates<Self>, Excluded) -> Void = { _, _ in },
        @QueryFragmentBuilder<Bool>
        where updateFilter: (TableColumns) -> [QueryFragment] = { _ in [] }
    ) -> InsertOf<Self> {
        withoutActuallyEscaping(updates) { updates in
            let (columnNames, processedValues) = nullPrimaryKeysDefaulted(values())

            return _insert(
                columnNames: columnNames,
                values: .values(processedValues),
                onConflict: conflictTargets,
                where: targetFilter(Self.columns),
                doUpdate: updates,
                where: updateFilter(Self.columns)
            )
        }
    }

    public static func insert<T1, each T2>(
        _ columns: (TableColumns) -> TableColumns = { $0 },
        @InsertValuesBuilder<Self> values: () -> [[QueryFragment]],
        onConflict conflictTargets: (TableColumns) -> (
            TableColumn<Self, T1>, repeat TableColumn<Self, each T2>
        ),
        @QueryFragmentBuilder<Bool>
        where targetFilter: (TableColumns) -> [QueryFragment] = { _ in [] },
        doUpdate updates: (inout Updates<Self>) -> Void,
        @QueryFragmentBuilder<Bool>
        where updateFilter: (TableColumns) -> [QueryFragment] = { _ in [] }
    ) -> InsertOf<Self> {
        insert(
            columns,
            values: values,
            onConflict: conflictTargets,
            where: targetFilter,
            doUpdate: { row, _ in updates(&row) },
            where: updateFilter
        )
    }

    private static func nullPrimaryKeysDefaulted(
        _ allValues: [[QueryFragment]]
    ) -> (columnNames: [String], values: [[QueryFragment]]) {

        let primaryKeyNames = Set(PrimaryTable.columns.primaryKey._names)

        var columnNames: [String] = []
        for column in TableColumns.writableColumns {

            columnNames.append(contentsOf: column._names)
        }

        var processedValues: [[QueryFragment]] = []
        for rowValues in allValues {
            var processedRow: [QueryFragment] = []

            for (column, value) in zip(TableColumns.writableColumns, rowValues) {
                let names = Set(column._names)
                let isPrimaryKeyColumn = !names.isDisjoint(with: primaryKeyNames)

                if isPrimaryKeyColumn && isNullBinding(value) {

                    processedRow.append(QueryFragment("DEFAULT"))
                } else {
                    processedRow.append(value)
                }
            }

            processedValues.append(processedRow)
        }

        return (columnNames, processedValues)
    }

    private static func isNullBinding(_ fragment: QueryFragment) -> Bool {

        if fragment.segments.isEmpty {
            return true
        }

        for segment in fragment.segments {

            if case .binding(.null) = segment {
                return true
            }

            if case .sql(let sql) = segment {
                let trimmed = sql.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
                if trimmed == "NULL" {
                    return true
                }
            }
        }
        return false
    }
}
