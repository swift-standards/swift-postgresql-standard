public import Foundation
public import Structured_Queries
import Structured_Queries_Support

extension Trigger.Function where On: Table {

    public static func updateTimestamp<D: _OptionalPromotable<Date?>>(
        column: KeyPath<On.TableColumns, TableColumn<On, D>>,
        to expression: any QueryExpression<D> = SQLQueryExpression("CURRENT_TIMESTAMP")
    ) -> Self {
        let columnName = On.columns[keyPath: column]._names[0]
        let functionName = "update_\(columnName)_\(On.tableName)"

        var body: QueryFragment = "NEW.\(quote: columnName) = "
        body.append(expression.queryFragment)
        body.append(";\nRETURN NEW;")

        return .plpgsql(functionName, body)
    }

    public static func createdAt<D: _OptionalPromotable<Date?>>(
        column: KeyPath<On.TableColumns, TableColumn<On, D>>,
        to expression: any QueryExpression<D> = SQLQueryExpression("CURRENT_TIMESTAMP")
    ) -> Self {
        let columnName = On.columns[keyPath: column]._names[0]
        let functionName = "set_\(columnName)_\(On.tableName)"

        var body: QueryFragment = "NEW.\(quote: columnName) = "
        body.append(expression.queryFragment)
        body.append(";\nRETURN NEW;")

        return .plpgsql(functionName, body)
    }

    public static func updateTimestamps<each D>(
        columns: repeat KeyPath<On.TableColumns, TableColumn<On, each D>>,
        to expression: any QueryExpression<Date?> = SQLQueryExpression("CURRENT_TIMESTAMP")
    ) -> Self {
        var columnNames: [String] = []
        for column in repeat each columns {
            columnNames.append(On.columns[keyPath: column]._names[0])
        }

        let functionName = "update_timestamps_\(On.tableName)"

        var body: QueryFragment = ""
        for (index, col) in columnNames.enumerated() {
            if index > 0 {
                body.append(";\n  ")
            }
            body.append("NEW.\(quote: col) = ")
            body.append(expression.queryFragment)
        }
        body.append(";\n  RETURN NEW;")

        return .plpgsql(functionName, body)
    }

    public static func incrementVersion<I: FixedWidthInteger>(
        column: KeyPath<On.TableColumns, TableColumn<On, I>>
    ) -> Self {
        let columnName = On.columns[keyPath: column]._names[0]
        let functionName = "increment_\(columnName)_\(On.tableName)"

        let body: QueryFragment = """
            NEW.\(quote: columnName) = OLD.\(quote: columnName) + 1;
            RETURN NEW;
            """

        return .plpgsql(functionName, body)
    }

    public static func audit<A: AuditTable>(
        to auditTable: A.Type
    ) -> Self {
        let auditTableName = A.tableName.quoted()
        let functionName = "audit_\(On.tableName)_to_\(A.tableName)"

        let body: QueryFragment = """
            INSERT INTO \(raw: auditTableName) (
              "tableName",
              operation,
              "oldData",
              "newData",
              "changedAt",
              "changedBy"
            ) VALUES (
              TG_TABLE_NAME,
              TG_OP,
              to_jsonb(OLD),
              to_jsonb(NEW),
              CURRENT_TIMESTAMP,
              current_user
            );
            RETURN COALESCE(NEW, OLD);
            """

        return .plpgsql(functionName, body)
    }

    public static func validate(_ validationLogic: String) -> Self {
        let functionName = "validate_\(On.tableName)"

        var body: QueryFragment = "\(raw: validationLogic)\n"
        body.append("RETURN NEW;")

        return .plpgsql(functionName, body)
    }

    public static func preventDeletion(message: String) -> Self {
        let functionName = "prevent_deletion_\(On.tableName)"
        let escapedMsg = message.escapedForPostgreSQL()

        let body: QueryFragment = "RAISE EXCEPTION '\(raw: escapedMsg)';"

        return .plpgsql(functionName, body)
    }

    public static func preventDeletionWhen<C: QueryBindable>(
        column: KeyPath<On.TableColumns, TableColumn<On, C>>,
        equals value: C,
        message: String
    ) -> Self {
        let columnName = On.columns[keyPath: column]._names[0].quoted()
        let functionName = "prevent_deletion_when_\(On.tableName)"
        let escapedMsg = message.escapedForPostgreSQL()

        var body: QueryFragment = "IF OLD.\(raw: columnName) = "
        body.append(value.queryFragment)
        body.append(" THEN\n  RAISE EXCEPTION '\(raw: escapedMsg)';\nEND IF;\nRETURN OLD;")

        return .plpgsql(functionName, body)
    }

    public static func softDelete<D: _OptionalPromotable<Date?>, I: QueryBindable>(
        deletedAtColumn: KeyPath<On.TableColumns, TableColumn<On, D>>,
        identifiedBy identifierColumn: KeyPath<On.TableColumns, TableColumn<On, I>>,
        to expression: any QueryExpression<D> = SQLQueryExpression("CURRENT_TIMESTAMP")
    ) -> Self {
        let columnName = On.columns[keyPath: deletedAtColumn]._names[0]
        let tableName = On.tableName.quoted()
        let idColumnName = On.columns[keyPath: identifierColumn]._names[0].quoted()
        let functionName = "soft_delete_\(On.tableName)"

        var body: QueryFragment = "UPDATE \(raw: tableName)\nSET \(quote: columnName) = "
        body.append(expression.queryFragment)
        body.append("\nWHERE \(raw: idColumnName) = OLD.\(raw: idColumnName);\nRETURN NULL;")

        return .plpgsql(functionName, body)
    }

    public static func enforceRowLevelSecurity<C: QueryBindable>(
        column: KeyPath<On.TableColumns, TableColumn<On, C>>,
        matches userContext: any QueryExpression<C>,
        message: String = "Access denied: row does not belong to current user"
    ) -> Self {
        let columnName = On.columns[keyPath: column]._names[0].quoted()
        let functionName = "enforce_rls_\(On.tableName)"
        let escapedMsg = message.escapedForPostgreSQL()

        var body: QueryFragment = "IF NEW.\(raw: columnName) != "
        body.append(userContext.queryFragment)
        body.append(" THEN\n  RAISE EXCEPTION '\(raw: escapedMsg)';\nEND IF;\nRETURN NEW;")

        return .plpgsql(functionName, body)
    }
}
