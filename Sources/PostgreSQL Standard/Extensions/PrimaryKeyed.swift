import Structured_Queries_Primitives

extension PrimaryKeyedTableDefinition where PrimaryColumn: TableColumnExpression {

    public func count(
        distinct isDistinct: Bool = false,
        filter: (some QueryExpression<Bool>)? = Bool?.none
    ) -> some QueryExpression<Int> {
        primaryKey.count(distinct: isDistinct, filter: filter)
    }
}

extension PrimaryKeyedTable {

    public static func find(
        _ primaryKey: some QueryExpression<PrimaryKey>
    ) -> Where<Self> {
        find([primaryKey])
    }

    public static func find(
        _ primaryKeys: some Swift.Sequence<some QueryExpression<PrimaryKey>>
    ) -> Where<Self> {
        Self.where { $0.primaryKey._in(primaryKeys) }
    }

    public var primaryKey: PrimaryKey.QueryOutput {
        self[keyPath: Self.columns.primaryKey.keyPath]
    }
}

extension TableDraft {

    public static func find(
        _ primaryKey: some QueryExpression<PrimaryKey>
    ) -> Where<Self> {
        find([primaryKey])
    }

    public static func find(
        _ primaryKeys: some Swift.Sequence<some QueryExpression<PrimaryKey>>
    ) -> Where<Self> {
        Self.where { $0.primaryKey._in(primaryKeys) }
    }
}

extension Where where From: PrimaryKeyedTable {

    public func find(_ primaryKey: some QueryExpression<From.PrimaryKey>) -> Self {
        find([primaryKey])
    }

    public func find(
        _ primaryKeys: some Swift.Sequence<some QueryExpression<From.PrimaryKey>>
    ) -> Self {
        Self.where { $0.primaryKey._in(primaryKeys) }
    }
}

extension Where where From: TableDraft {

    public func find(
        _ primaryKey: some QueryExpression<From.PrimaryKey>
    )
        -> Self
    {
        find([primaryKey])
    }

    public func find(
        _ primaryKeys: some Swift.Sequence<some QueryExpression<From.PrimaryKey>>
    ) -> Self {
        Self.where { $0.primaryKey._in(primaryKeys) }
    }
}

extension Select where From: PrimaryKeyedTable {

    public func find(_ primaryKey: some QueryExpression<From.PrimaryKey>) -> Self {
        and(From.find(primaryKey))
    }

    public func find(
        _ primaryKeys: some Swift.Sequence<some QueryExpression<From.PrimaryKey>>
    ) -> Self {
        and(From.find(primaryKeys))
    }
}

extension Select where From: TableDraft {

    public func find(
        _ primaryKey: some QueryExpression<From.PrimaryKey>
    ) -> Self {
        and(From.find(primaryKey))
    }

    public func find(
        _ primaryKeys: some Swift.Sequence<some QueryExpression<From.PrimaryKey>>
    ) -> Self {
        and(From.find(primaryKeys))
    }
}

extension Update where From: PrimaryKeyedTable {

    public func find(_ primaryKey: some QueryExpression<From.PrimaryKey>) -> Self {
        find([primaryKey])
    }

    public func find(
        _ primaryKeys: some Swift.Sequence<some QueryExpression<From.PrimaryKey>>
    ) -> Self {
        self.where { $0.primaryKey._in(primaryKeys) }
    }
}

extension Update where From: TableDraft {

    public func find(
        _ primaryKey: some QueryExpression<From.PrimaryKey>
    )
        -> Self
    {
        find([primaryKey])
    }

    public func find(
        _ primaryKeys: some Swift.Sequence<some QueryExpression<From.PrimaryKey>>
    ) -> Self {
        self.where { $0.primaryKey._in(primaryKeys) }
    }
}

extension Delete where From: PrimaryKeyedTable {

    public func find(_ primaryKey: some QueryExpression<From.PrimaryKey>) -> Self {
        find([primaryKey])
    }

    public func find(
        _ primaryKeys: some Swift.Sequence<some QueryExpression<From.PrimaryKey>>
    ) -> Self {
        self.where { $0.primaryKey._in(primaryKeys) }
    }
}

extension Delete where From: TableDraft {

    public func find(
        _ primaryKey: some QueryExpression<From.PrimaryKey>
    )
        -> Self
    {
        find([primaryKey])
    }

    public func find(
        _ primaryKeys: some Swift.Sequence<some QueryExpression<From.PrimaryKey>>
    ) -> Self {
        self.where { $0.primaryKey._in(primaryKeys) }
    }
}
