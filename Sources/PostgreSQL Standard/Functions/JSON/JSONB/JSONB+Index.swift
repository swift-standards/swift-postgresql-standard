public import Foundation
import Structured_Queries_Primitives

extension JSONB {

    public enum Index {}
}

extension JSONB.Index {

    public enum GIN: String, Sendable {

        case jsonb_ops

        case jsonb_path_ops
    }
}

extension Table {

    public static func createGINIndex(
        name: String? = nil,
        on column: KeyPath<TableColumns, TableColumn<Self, some _JSONBRepresentationProtocol>>,
        operatorClass: JSONB.Index.GIN = .jsonb_ops
    ) -> QueryFragment {
        let col = columns[keyPath: column]
        let indexName = name ?? "idx_\(tableName)_\(col.name)_gin"
        let opClass = operatorClass == .jsonb_ops ? "" : " \(operatorClass.rawValue)"

        var fragment: QueryFragment = "CREATE INDEX \(quote: indexName) ON "
        if let schemaName {
            fragment.append("\(quote: schemaName).")
        }
        fragment.append("\(quote: tableName) USING GIN (\(quote: col.name)\(raw: opClass))")

        return fragment
    }

    public static func createGINIndexPath(
        name: String? = nil,
        on column: KeyPath<TableColumns, TableColumn<Self, some _JSONBRepresentationProtocol>>,
        path: [String],
        operatorClass: JSONB.Index.GIN = .jsonb_ops
    ) -> QueryFragment {
        let col = columns[keyPath: column]
        let indexName = name ?? "idx_\(tableName)_\(col.name)_\(path.joined(separator: "_"))_gin"

        let pathExpr = JSONB.TextPath(path).literalFragment
        let opClass = operatorClass == .jsonb_ops ? "" : " \(operatorClass.rawValue)"

        var fragment: QueryFragment = "CREATE INDEX \(quote: indexName) ON "
        if let schemaName {
            fragment.append("\(quote: schemaName).")
        }
        fragment.append(
            "\(quote: tableName) USING GIN ((\(quote: col.name) #> \(pathExpr))\(raw: opClass))"
        )

        return fragment
    }

    public static func createBTreeIndex(
        name: String? = nil,
        on column: KeyPath<TableColumns, TableColumn<Self, some _JSONBRepresentationProtocol>>
    ) -> QueryFragment {
        let col = columns[keyPath: column]
        let indexName = name ?? "idx_\(tableName)_\(col.name)_btree"

        var fragment: QueryFragment = "CREATE INDEX \(quote: indexName) ON "
        if let schemaName {
            fragment.append("\(quote: schemaName).")
        }
        fragment.append("\(quote: tableName) USING BTREE (\(quote: col.name))")

        return fragment
    }

    public static func dropIndex(name: String, ifExists: Bool = true) -> QueryFragment {
        var fragment: QueryFragment = "DROP INDEX "
        if ifExists {
            fragment.append("IF EXISTS ")
        }
        if let schemaName {
            fragment.append("\(quote: schemaName).")
        }
        fragment.append("\(quote: name)")
        return fragment
    }
}

extension Table {

    public static func createGINIndex(
        name: String? = nil,
        on column: KeyPath<TableColumns, TableColumn<Self, Data>>,
        operatorClass: JSONB.Index.GIN = .jsonb_ops
    ) -> QueryFragment {
        let col = columns[keyPath: column]
        let indexName = name ?? "idx_\(tableName)_\(col.name)_gin"
        let opClass = operatorClass == .jsonb_ops ? "" : " \(operatorClass.rawValue)"

        var fragment: QueryFragment = "CREATE INDEX \(quote: indexName) ON "
        if let schemaName {
            fragment.append("\(quote: schemaName).")
        }
        fragment.append("\(quote: tableName) USING GIN (\(quote: col.name)\(raw: opClass))")

        return fragment
    }

    public static func createGINIndexPath(
        name: String? = nil,
        on column: KeyPath<TableColumns, TableColumn<Self, Data>>,
        path: [String],
        operatorClass: JSONB.Index.GIN = .jsonb_ops
    ) -> QueryFragment {
        let col = columns[keyPath: column]
        let indexName = name ?? "idx_\(tableName)_\(col.name)_\(path.joined(separator: "_"))_gin"

        let pathExpr = JSONB.TextPath(path).literalFragment
        let opClass = operatorClass == .jsonb_ops ? "" : " \(operatorClass.rawValue)"

        var fragment: QueryFragment = "CREATE INDEX \(quote: indexName) ON "
        if let schemaName {
            fragment.append("\(quote: schemaName).")
        }
        fragment.append(
            "\(quote: tableName) USING GIN ((\(quote: col.name) #> \(pathExpr))\(raw: opClass))"
        )

        return fragment
    }

    public static func createBTreeIndex(
        name: String? = nil,
        on column: KeyPath<TableColumns, TableColumn<Self, Data>>
    ) -> QueryFragment {
        let col = columns[keyPath: column]
        let indexName = name ?? "idx_\(tableName)_\(col.name)_btree"

        var fragment: QueryFragment = "CREATE INDEX \(quote: indexName) ON "
        if let schemaName {
            fragment.append("\(quote: schemaName).")
        }
        fragment.append("\(quote: tableName) USING BTREE (\(quote: col.name))")

        return fragment
    }
}
