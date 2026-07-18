import MacroTesting
import PostgreSQL_Standard_Macros_Implementation
import Testing

extension SnapshotTests {
    @MainActor
    @Suite struct DraftWritableColumnsTests {
        @Test func draftExcludesPrimaryKeyFromWritableColumns() {
            assertMacro {
                """
                @Table
                struct User {
                  let id: Int
                  var name: String
                  var email: String
                }
                """
            } expansion: {
                #"""
                struct User {
                  let id: Int
                  var name: String
                  var email: String

                  public nonisolated struct TableColumns: Structured_Queries_Primitives.TableDefinition, Structured_Queries_Primitives.PrimaryKeyedTableDefinition {
                    public typealias QueryValue = User
                    public typealias PrimaryKey = Int
                    public let id = Structured_Queries_Primitives._TableColumn<QueryValue, Int>.for("id", keyPath: \QueryValue.id)
                    public let primaryKey = Structured_Queries_Primitives._TableColumn<QueryValue, Int>.for("id", keyPath: \QueryValue.id)
                    public let name = Structured_Queries_Primitives._TableColumn<QueryValue, String>.for("name", keyPath: \QueryValue.name)
                    public let email = Structured_Queries_Primitives._TableColumn<QueryValue, String>.for("email", keyPath: \QueryValue.email)
                    public static var allColumns: [any Structured_Queries_Primitives.TableColumnExpression] {
                      var allColumns: [any Structured_Queries_Primitives.TableColumnExpression] = []
                      allColumns.append(contentsOf: QueryValue.columns.id._allColumns)
                      allColumns.append(contentsOf: QueryValue.columns.name._allColumns)
                      allColumns.append(contentsOf: QueryValue.columns.email._allColumns)
                      return allColumns
                    }
                    public static var writableColumns: [any Structured_Queries_Primitives.WritableTableColumnExpression] {
                      var writableColumns: [any Structured_Queries_Primitives.WritableTableColumnExpression] = []
                      writableColumns.append(contentsOf: QueryValue.columns.id._writableColumns)
                      writableColumns.append(contentsOf: QueryValue.columns.name._writableColumns)
                      writableColumns.append(contentsOf: QueryValue.columns.email._writableColumns)
                      return writableColumns
                    }
                    public var queryFragment: QueryFragment {
                      "\(self.id), \(self.name), \(self.email)"
                    }
                  }

                  public nonisolated struct Selection: Structured_Queries_Primitives.TableExpression {
                    public typealias QueryValue = User
                    public let allColumns: [any Structured_Queries_Primitives.QueryExpression]
                    public init(
                      id: some Structured_Queries_Primitives.QueryExpression<Int>,
                      name: some Structured_Queries_Primitives.QueryExpression<String>,
                      email: some Structured_Queries_Primitives.QueryExpression<String>
                    ) {
                      var allColumns: [any Structured_Queries_Primitives.QueryExpression] = []
                      allColumns.append(contentsOf: id._allColumns)
                      allColumns.append(contentsOf: name._allColumns)
                      allColumns.append(contentsOf: email._allColumns)
                      self.allColumns = allColumns
                    }
                  }

                  public struct Draft: Structured_Queries_Primitives.TableDraft {
                    public typealias PrimaryTable = User
                    let id: Int?
                    var name: String
                    var email: String
                    public nonisolated struct TableColumns: Structured_Queries_Primitives.TableDefinition {
                      public typealias QueryValue = Draft
                      public let id = Structured_Queries_Primitives._TableColumn<QueryValue, Int?>.for("id", keyPath: \QueryValue.id, default: nil)
                      public let name = Structured_Queries_Primitives._TableColumn<QueryValue, String>.for("name", keyPath: \QueryValue.name)
                      public let email = Structured_Queries_Primitives._TableColumn<QueryValue, String>.for("email", keyPath: \QueryValue.email)
                      public static var allColumns: [any Structured_Queries_Primitives.TableColumnExpression] {
                        var allColumns: [any Structured_Queries_Primitives.TableColumnExpression] = []
                        allColumns.append(contentsOf: QueryValue.columns.id._allColumns)
                        allColumns.append(contentsOf: QueryValue.columns.name._allColumns)
                        allColumns.append(contentsOf: QueryValue.columns.email._allColumns)
                        return allColumns
                      }
                      public static var writableColumns: [any Structured_Queries_Primitives.WritableTableColumnExpression] {
                        var writableColumns: [any Structured_Queries_Primitives.WritableTableColumnExpression] = []
                        writableColumns.append(contentsOf: QueryValue.columns.id._writableColumns)
                        writableColumns.append(contentsOf: QueryValue.columns.name._writableColumns)
                        writableColumns.append(contentsOf: QueryValue.columns.email._writableColumns)
                        return writableColumns
                      }
                      public var queryFragment: QueryFragment {
                        "\(self.id), \(self.name), \(self.email)"
                      }
                    }
                    public nonisolated struct Selection: Structured_Queries_Primitives.TableExpression {
                      public typealias QueryValue = Draft
                      public let allColumns: [any Structured_Queries_Primitives.QueryExpression]
                      public init(
                        id: some Structured_Queries_Primitives.QueryExpression<Int?> = Int?(queryOutput: nil),
                        name: some Structured_Queries_Primitives.QueryExpression<String>,
                        email: some Structured_Queries_Primitives.QueryExpression<String>
                      ) {
                        var allColumns: [any Structured_Queries_Primitives.QueryExpression] = []
                        allColumns.append(contentsOf: id._allColumns)
                        allColumns.append(contentsOf: name._allColumns)
                        allColumns.append(contentsOf: email._allColumns)
                        self.allColumns = allColumns
                      }
                    }
                    public typealias QueryValue = Self

                    public typealias From = Swift.Never

                    public nonisolated static var columns: TableColumns {
                      TableColumns()
                    }

                    public nonisolated static var _columnWidth: Int {
                      var columnWidth = 0
                      columnWidth += Int?._columnWidth
                      columnWidth += String._columnWidth
                      columnWidth += String._columnWidth
                      return columnWidth
                    }

                    public nonisolated static var tableName: String {
                      User.tableName
                    }

                    public nonisolated init(decoder: inout some Structured_Queries_Primitives.QueryDecoder) throws {
                      self.id = try decoder.decode(Int.self) ?? nil
                      let name = try decoder.decode(String.self)
                      let email = try decoder.decode(String.self)
                      guard let name else {
                        throw Structured_Queries_Primitives.QueryDecodingError.missingRequiredColumn
                      }
                      guard let email else {
                        throw Structured_Queries_Primitives.QueryDecodingError.missingRequiredColumn
                      }
                      self.name = name
                      self.email = email
                    }

                    public nonisolated init(_ other: User) {
                      self.id = other.id
                      self.name = other.name
                      self.email = other.email
                    }
                    public init(
                      id: Int? = nil,
                      name: String,
                      email: String
                    ) {
                      self.id = id
                      self.name = name
                      self.email = email
                    }
                  }
                }

                nonisolated extension User: Structured_Queries_Primitives.Table, Structured_Queries_Primitives.PrimaryKeyedTable, Structured_Queries_Primitives.PartialSelectStatement {
                  public typealias QueryValue = Self
                  public typealias From = Swift.Never
                  public nonisolated static var columns: TableColumns {
                    TableColumns()
                  }
                  public nonisolated static var _columnWidth: Int {
                    var columnWidth = 0
                    columnWidth += Int._columnWidth
                    columnWidth += String._columnWidth
                    columnWidth += String._columnWidth
                    return columnWidth
                  }
                  public nonisolated static var tableName: String {
                    "users"
                  }
                  public nonisolated init(decoder: inout some Structured_Queries_Primitives.QueryDecoder) throws {
                    let id = try decoder.decode(Int.self)
                    let name = try decoder.decode(String.self)
                    let email = try decoder.decode(String.self)
                    guard let id else {
                      throw Structured_Queries_Primitives.QueryDecodingError.missingRequiredColumn
                    }
                    guard let name else {
                      throw Structured_Queries_Primitives.QueryDecodingError.missingRequiredColumn
                    }
                    guard let email else {
                      throw Structured_Queries_Primitives.QueryDecodingError.missingRequiredColumn
                    }
                    self.id = id
                    self.name = name
                    self.email = email
                  }
                }
                """#
            }
        }
    }
}
