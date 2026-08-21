public import PostgreSQL_Standard

@attached(
    extension,
    conformances: Table,
    PartialSelectStatement,
    PrimaryKeyedTable,
    names: named(From),
    named(columns),
    named(_columnWidth),
    named(init(_:)),
    named(init(decoder:)),
    named(QueryValue),
    named(schemaName),
    named(tableName)
)
@attached(member, names: named(Draft), named(Selection), named(TableColumns))
@attached(memberAttribute)
public macro Table(
    _ name: String = "",
    schema schemaName: String = ""
) =
    #externalMacro(
        module: "PostgreSQL_Standard_Macros_Implementation",
        type: "TableMacro"
    )

@attached(
    extension,
    conformances: _Selection,
    Table,
    PartialSelectStatement,
    PrimaryKeyedTable,
    names: named(From),
    named(columns),
    named(_columnWidth),
    named(init(_:)),
    named(init(decoder:)),
    named(QueryValue),
    named(schemaName),
    named(tableName)
)
@attached(member, names: named(Draft), named(Selection), named(TableColumns))
@attached(memberAttribute)
public macro Selection(
    _ name: String = ""
) =
    #externalMacro(
        module: "PostgreSQL_Standard_Macros_Implementation",
        type: "TableMacro"
    )

@attached(peer)
public macro Column(
    _ name: String = "",
    as representableType: (any QueryRepresentable.Type)? = nil,
    generated: GeneratedColumnStorage? = nil,
    primaryKey: Bool = false
) =
    #externalMacro(
        module: "PostgreSQL_Standard_Macros_Implementation",
        type: "ColumnMacro"
    )

@attached(peer)
public macro Columns(

    primaryKey: Bool = false
) =
    #externalMacro(
        module: "PostgreSQL_Standard_Macros_Implementation",
        type: "ColumnsMacro"
    )

@attached(peer)
public macro Ephemeral() =
    #externalMacro(
        module: "PostgreSQL_Standard_Macros_Implementation",
        type: "EphemeralMacro"
    )

@freestanding(expression)
public macro bind<QueryValue: QueryBindable>(
    _ queryValue: QueryValue.QueryOutput,
    as queryValueType: QueryValue.Type = QueryValue.self
) -> BindQueryExpression<QueryValue> =
    #externalMacro(module: "PostgreSQL_Standard_Macros_Implementation", type: "BindMacro")

@freestanding(expression)
public macro sql<QueryValue>(
    _ queryFragment: QueryFragment,
    as queryValueType: QueryValue.Type = QueryValue.self
) -> SQLQueryExpression<QueryValue> =
    #externalMacro(module: "PostgreSQL_Standard_Macros_Implementation", type: "SQLMacro")

@freestanding(expression)
public macro sql(
    _ queryFragment: QueryFragment,
    as queryValueType: Any.Type = Any.self
) -> SQLQueryExpression<Any> =
    #externalMacro(module: "PostgreSQL_Standard_Macros_Implementation", type: "SQLMacro")
