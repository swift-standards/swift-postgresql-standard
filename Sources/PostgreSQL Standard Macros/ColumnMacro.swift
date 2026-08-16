public import SwiftSyntax
public import SwiftSyntaxMacros

public enum ColumnMacro: PeerMacro {}

extension ColumnMacro {
    // swiftlint:disable typed_throws_required
    // REASON: PeerMacro requires this external witness signature.
    public static func expansion<D: DeclSyntaxProtocol, C: MacroExpansionContext>(
        of node: AttributeSyntax,
        providingPeersOf declaration: D,
        in context: C
    ) throws -> [DeclSyntax] {
        []
    }
    // swiftlint:enable typed_throws_required
}
