import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct PostgreSQLStandardPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        BindMacro.self,
        ColumnMacro.self,
        ColumnsMacro.self,
        EphemeralMacro.self,
        SQLMacro.self,
        TableMacro.self,
    ]
}
