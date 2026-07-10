import MacroTesting
import PostgreSQL_Standard_Macros
import Testing
import Tests_Snapshot

@MainActor
@Suite(
    .serialized,
    .macros(
        [
            "_Draft": TableMacro.self,
            "bind": BindMacro.self,
            "Column": ColumnMacro.self,
            "Columns": ColumnsMacro.self,
            "Ephemeral": EphemeralMacro.self,
            "Selection": TableMacro.self,
            "sql": SQLMacro.self,
            "Table": TableMacro.self,
        ],
        record: .never
    )
) struct SnapshotTests {}
