import MacroTesting
import PostgreSQL_Standard_Macros_Implementation
import Testing

extension SnapshotTests {
    @MainActor
    @Suite struct BindMacroTests {
        @Test func basics() {
            assertMacro {
                #"""
                \(date) < #bind(Date())
                """#
            } expansion: {
                #"""
                \(date) < Structured_Queries_Primitives.BindQueryExpression(Date())
                """#
            }
        }

        @Test func queryValueType() {
            assertMacro {
                #"""
                \(date) < #bind(Date(), as: Date.UnixTimeRepresentation.self)
                """#
            } expansion: {
                #"""
                \(date) < Structured_Queries_Primitives.BindQueryExpression(Date(), as: Date.UnixTimeRepresentation.self)
                """#
            }
        }
    }
}
