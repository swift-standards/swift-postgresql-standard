import Foundation

extension TableDraft {
    /// An insert statement for one or more draft rows with PostgreSQL NULL handling.
    ///
    /// Parity override of the plain `Table.insert` entry point for draft types, matching the
    /// `PrimaryKeyedTable` draft overloads in `Insert+PrimaryKeyedTable.swift`. Upstream SQLite
    /// auto-assigns NULL primary keys on insert; PostgreSQL rejects them (error 23502), so
    /// NULL-valued primary keys are emitted as DEFAULT. Without this override, a direct
    /// `Draft.insert { draft }` resolves to the generic `Table.insert` and binds NULL into the
    /// primary-key slot.
    ///
    /// - Parameters:
    ///   - columns: Columns to insert.
    ///   - values: A builder of draft values for the given columns.
    ///   - updates: Updates to perform in an upsert clause should the insert conflict.
    ///   - updateFilter: A filter to apply to the update clause.
    /// - Returns: An insert statement.
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

    /// An insert statement for one or more draft rows (single update parameter).
    ///
    /// Parity override of the corresponding `Table.insert` entry point — the generic version
    /// delegates within the defining module, so it must be shadowed here as well or calls in
    /// this shape bypass the NULL→DEFAULT translation.
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

    /// An insert statement with conflict resolution for one or more draft rows.
    ///
    /// Parity override of the conflict-target `Table.insert` entry point with PostgreSQL
    /// NULL handling. The primary-key column is included with DEFAULT for NULL values so
    /// that ON CONFLICT targeting the primary key remains valid.
    ///
    /// - Parameters:
    ///   - columns: Columns to insert.
    ///   - values: A builder of draft values for the given columns.
    ///   - conflictTargets: Columns to target for conflict resolution.
    ///   - targetFilter: A filter to apply to conflict target columns.
    ///   - updates: Updates to perform in an upsert clause should the insert conflict.
    ///   - updateFilter: A filter to apply to the update clause.
    /// - Returns: An insert statement.
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

    /// An insert statement with conflict resolution for draft rows (single update parameter).
    ///
    /// Parity override of the corresponding `Table.insert` entry point — see the two-parameter
    /// variant above.
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

    /// Translates NULL primary-key bindings to DEFAULT across the given rows.
    ///
    /// Always includes all writable draft columns (matching the `PrimaryKeyedTable` draft
    /// overloads); only the primary-key slots with NULL values are rewritten.
    private static func nullPrimaryKeysDefaulted(
        _ allValues: [[QueryFragment]]
    ) -> (columnNames: [String], values: [[QueryFragment]]) {
        // Get ALL primary key column names (handles both single columns and column groups)
        let primaryKeyNames = Set(PrimaryTable.columns.primaryKey._names)

        var columnNames: [String] = []
        for column in TableColumns.writableColumns {
            // For column groups, append all names
            columnNames.append(contentsOf: column._names)
        }

        var processedValues: [[QueryFragment]] = []
        for rowValues in allValues {
            var processedRow: [QueryFragment] = []

            for (column, value) in zip(TableColumns.writableColumns, rowValues) {
                let names = Set(column._names)
                let isPrimaryKeyColumn = !names.isDisjoint(with: primaryKeyNames)

                if isPrimaryKeyColumn && isNullBinding(value) {
                    // PostgreSQL: Translate NULL to DEFAULT for primary key columns
                    processedRow.append(QueryFragment("DEFAULT"))
                } else {
                    processedRow.append(value)
                }
            }

            processedValues.append(processedRow)
        }

        return (columnNames, processedValues)
    }

    /// Helper function to check if a QueryFragment represents NULL
    private static func isNullBinding(_ fragment: QueryFragment) -> Bool {
        // Empty fragment typically means NULL
        if fragment.segments.isEmpty {
            return true
        }

        // Check each segment
        for segment in fragment.segments {
            // Check for null binding
            if case .binding(.null) = segment {
                return true
            }

            // Check for SQL "NULL" literal
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
