import Foundation

extension PrimaryKeyedTable where TableColumns.PrimaryColumn: TableColumnExpression {

    public static func insert(
        _ columns: (TableColumns) -> TableColumns = { $0 },
        @InsertValuesBuilder<Self> values: () -> [[QueryFragment]],
        onConflictDoUpdate updates: ((inout Updates<Self>, Excluded) -> Void)? = nil,
        @QueryFragmentBuilder<Bool>
        where updateFilter: (TableColumns) -> [QueryFragment] = { _ in [] }
    ) -> InsertOf<Self> {

        let allValues = values()

        let primaryKeyNames = Set(Self.columns.primaryKey._names)

        var hasAnyExplicitPrimaryKey = false
        var hasAnyNullPrimaryKey = false

        for rowValues in allValues {
            for (column, value) in zip(TableColumns.writableColumns, rowValues) {

                let columnNames = Set(column._names)
                let isPrimaryKeyColumn = !columnNames.isDisjoint(with: primaryKeyNames)

                if isPrimaryKeyColumn {
                    if isNullBinding(value) {
                        hasAnyNullPrimaryKey = true
                    } else {
                        hasAnyExplicitPrimaryKey = true
                    }
                    break
                }
            }
        }

        if hasAnyExplicitPrimaryKey && hasAnyNullPrimaryKey {
            var processedValues: [[QueryFragment]] = []

            for rowValues in allValues {
                var processedRow: [QueryFragment] = []
                for (column, value) in zip(TableColumns.writableColumns, rowValues) {
                    let columnNames = Set(column._names)
                    let isPrimaryKeyColumn = !columnNames.isDisjoint(with: primaryKeyNames)

                    if isPrimaryKeyColumn && isNullBinding(value) {

                        processedRow.append(QueryFragment("DEFAULT"))
                    } else {
                        processedRow.append(value)
                    }
                }
                processedValues.append(processedRow)
            }

            return _insert(
                columnNames: TableColumns.writableColumns.map(\.name),
                values: .values(processedValues),
                onConflict: { _ -> ()? in nil },
                where: [],
                doUpdate: updates,
                where: updateFilter(Self.columns)
            )
        }

        return _insert(
            columnNames: TableColumns.writableColumns.map(\.name),
            values: .values(allValues),
            onConflict: { _ -> ()? in nil },
            where: [],
            doUpdate: updates,
            where: updateFilter(Self.columns)
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

            let allValues = values()

            let primaryKeyNames = Set(Self.columns.primaryKey._names)

            var hasAnyExplicitPrimaryKey = false
            var hasAnyNullPrimaryKey = false

            for rowValues in allValues {
                for (column, value) in zip(TableColumns.writableColumns, rowValues) {
                    let columnNames = Set(column._names)
                    let isPrimaryKeyColumn = !columnNames.isDisjoint(with: primaryKeyNames)

                    if isPrimaryKeyColumn {
                        if isNullBinding(value) {
                            hasAnyNullPrimaryKey = true
                        } else {
                            hasAnyExplicitPrimaryKey = true
                        }
                        break
                    }
                }
            }

            if hasAnyNullPrimaryKey && !hasAnyExplicitPrimaryKey {

                var filteredColumnNames: [String] = []
                var filteredValues: [[QueryFragment]] = []

                for (index, rowValues) in allValues.enumerated() {
                    var filteredRowValues: [QueryFragment] = []

                    if index == 0 {
                        for column in TableColumns.writableColumns {
                            let columnNames = Set(column._names)
                            let isPrimaryKeyColumn = !columnNames.isDisjoint(with: primaryKeyNames)

                            if !isPrimaryKeyColumn {

                                filteredColumnNames.append(contentsOf: column._names)
                            }
                        }
                    }

                    for (column, value) in zip(TableColumns.writableColumns, rowValues) {
                        let columnNames = Set(column._names)
                        let isPrimaryKeyColumn = !columnNames.isDisjoint(with: primaryKeyNames)

                        if !isPrimaryKeyColumn {
                            filteredRowValues.append(value)
                        }
                    }

                    filteredValues.append(filteredRowValues)
                }

                return _insert(
                    columnNames: filteredColumnNames,
                    values: .values(filteredValues),
                    onConflict: conflictTargets,
                    where: targetFilter(Self.columns),
                    doUpdate: updates,
                    where: updateFilter(Self.columns)
                )
            }

            if hasAnyExplicitPrimaryKey && hasAnyNullPrimaryKey {
                var processedValues: [[QueryFragment]] = []

                for rowValues in allValues {
                    var processedRow: [QueryFragment] = []
                    for (column, value) in zip(TableColumns.writableColumns, rowValues) {
                        let columnNames = Set(column._names)
                        let isPrimaryKeyColumn = !columnNames.isDisjoint(with: primaryKeyNames)

                        if isPrimaryKeyColumn && isNullBinding(value) {
                            processedRow.append(QueryFragment("DEFAULT"))
                        } else {
                            processedRow.append(value)
                        }
                    }
                    processedValues.append(processedRow)
                }

                return _insert(
                    columnNames: TableColumns.writableColumns.map(\.name),
                    values: .values(processedValues),
                    onConflict: conflictTargets,
                    where: targetFilter(Self.columns),
                    doUpdate: updates,
                    where: updateFilter(Self.columns)
                )
            }

            return _insert(
                columnNames: TableColumns.writableColumns.map(\.name),
                values: .values(allValues),
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

    public static func insert(
        @InsertValuesBuilder<Draft> values: () -> [[QueryFragment]],
        onConflictDoUpdate updates: ((inout Updates<Self>, Excluded) -> Void)? = nil,
        @QueryFragmentBuilder<Bool>
        where updateFilter: (TableColumns) -> [QueryFragment] = { _ in [] }
    ) -> InsertOf<Self> {

        let allValues = values()

        let primaryKeyNames = Set(columns.primaryKey._names)

        var hasAnyExplicitPrimaryKey = false

        for rowValues in allValues {
            for (column, value) in zip(Draft.TableColumns.writableColumns, rowValues) {
                let columnNames = Set(column._names)
                let isPrimaryKeyColumn = !columnNames.isDisjoint(with: primaryKeyNames)

                if isPrimaryKeyColumn && !isNullBinding(value) {
                    hasAnyExplicitPrimaryKey = true
                    break
                }
            }
            if hasAnyExplicitPrimaryKey { break }
        }

        var filteredColumnNames: [String] = []
        var filteredValues: [[QueryFragment]] = []

        for column in Draft.TableColumns.writableColumns {
            filteredColumnNames.append(contentsOf: column._names)
        }

        for rowValues in allValues {
            var filteredRowValues: [QueryFragment] = []

            for (column, value) in zip(Draft.TableColumns.writableColumns, rowValues) {
                let columnNames = Set(column._names)
                let isPrimaryKeyColumn = !columnNames.isDisjoint(with: primaryKeyNames)

                if isPrimaryKeyColumn && isNullBinding(value) {

                    filteredRowValues.append(QueryFragment("DEFAULT"))
                } else {
                    filteredRowValues.append(value)
                }
            }

            filteredValues.append(filteredRowValues)
        }

        return _insert(
            columnNames: filteredColumnNames,
            values: .values(filteredValues),
            onConflict: { _ -> ()? in nil },
            where: [],
            doUpdate: updates,
            where: updateFilter(Self.columns)
        )
    }

    public static func insert<T1, each T2>(
        @InsertValuesBuilder<Draft> values: () -> [[QueryFragment]],
        onConflict conflictTargets: (TableColumns) -> (
            TableColumn<Self, T1>, repeat TableColumn<Self, each T2>
        ),
        @QueryFragmentBuilder<Bool>
        where targetFilter: (TableColumns) -> [QueryFragment] = { _ in [] },
        doUpdate updates: (inout Updates<Self>, Excluded) -> Void = { _, _ in },
        @QueryFragmentBuilder<Bool>
        where updateFilter: (TableColumns) -> [QueryFragment] = { _ in [] }
    ) -> InsertOf<Self> {

        let allValues = values()

        let primaryKeyNames = Set(columns.primaryKey._names)

        var hasAnyExplicitPrimaryKey = false
        var hasAnyNullPrimaryKey = false

        for rowValues in allValues {
            for (column, value) in zip(Draft.TableColumns.writableColumns, rowValues) {
                let columnNames = Set(column._names)
                let isPrimaryKeyColumn = !columnNames.isDisjoint(with: primaryKeyNames)

                if isPrimaryKeyColumn {
                    if isNullBinding(value) {
                        hasAnyNullPrimaryKey = true
                    } else {
                        hasAnyExplicitPrimaryKey = true
                    }
                    break
                }
            }
        }

        let shouldIncludePrimaryKey = hasAnyExplicitPrimaryKey || hasAnyNullPrimaryKey

        var filteredColumnNames: [String] = []
        var filteredValues: [[QueryFragment]] = []

        for rowValues in allValues {
            var filteredRowValues: [QueryFragment] = []

            if filteredColumnNames.isEmpty {
                for column in Draft.TableColumns.writableColumns {
                    let columnNames = Set(column._names)
                    let isPrimaryKeyColumn = !columnNames.isDisjoint(with: primaryKeyNames)

                    if isPrimaryKeyColumn && !shouldIncludePrimaryKey {
                        continue
                    }

                    filteredColumnNames.append(contentsOf: column._names)
                }
            }

            for (column, value) in zip(Draft.TableColumns.writableColumns, rowValues) {
                let columnNames = Set(column._names)
                let isPrimaryKeyColumn = !columnNames.isDisjoint(with: primaryKeyNames)

                if isPrimaryKeyColumn {
                    if shouldIncludePrimaryKey {

                        if isNullBinding(value) {

                            filteredRowValues.append(QueryFragment("DEFAULT"))
                        } else {
                            filteredRowValues.append(value)
                        }
                    }

                } else {

                    filteredRowValues.append(value)
                }
            }

            filteredValues.append(filteredRowValues)
        }

        return withoutActuallyEscaping(updates) { updates in
            _insert(
                columnNames: filteredColumnNames,
                values: .values(filteredValues),
                onConflict: conflictTargets,
                where: targetFilter(Self.columns),
                doUpdate: updates,
                where: updateFilter(Self.columns)
            )
        }
    }

    public static func upsert(
        @InsertValuesBuilder<Draft> values: () -> [[QueryFragment]]
    ) -> InsertOf<Self> {

        let allValues = values()

        let primaryKeyNames = Set(columns.primaryKey._names)

        var filteredColumnNames: [String] = []
        var filteredValues: [[QueryFragment]] = []

        var hasAnyExplicitPrimaryKey = false
        for rowValues in allValues {
            for (column, value) in zip(Draft.TableColumns.writableColumns, rowValues) {
                let columnNames = Set(column._names)
                let isPrimaryKeyColumn = !columnNames.isDisjoint(with: primaryKeyNames)

                if isPrimaryKeyColumn && !isNullBinding(value) {
                    hasAnyExplicitPrimaryKey = true
                    break
                }
            }
            if hasAnyExplicitPrimaryKey { break }
        }

        for column in Draft.TableColumns.writableColumns {

            filteredColumnNames.append(contentsOf: column._names)
        }

        for rowValues in allValues {
            var filteredRowValues: [QueryFragment] = []

            for (column, value) in zip(Draft.TableColumns.writableColumns, rowValues) {
                let columnNames = Set(column._names)
                let isPrimaryKeyColumn = !columnNames.isDisjoint(with: primaryKeyNames)

                if isPrimaryKeyColumn && isNullBinding(value) {

                    filteredRowValues.append(QueryFragment("DEFAULT"))
                } else {
                    filteredRowValues.append(value)
                }
            }

            filteredValues.append(filteredRowValues)
        }

        return _insert(
            columnNames: filteredColumnNames,
            values: .values(filteredValues),
            onConflict: { cols in cols.primaryKey },
            where: [],
            doUpdate: { updates, _ in

                for columnName in filteredColumnNames {

                    if !primaryKeyNames.contains(columnName) {

                        if let excludedColumn = Excluded.writableColumns.first(where: {
                            $0.name == columnName
                        }) {

                            if let originalColumn = Draft.TableColumns.writableColumns.first(
                                where: { $0.name == columnName })
                            {
                                updates.set(originalColumn, excludedColumn.queryFragment)
                            }
                        }
                    }
                }
            },
            where: []
        )
    }
}
