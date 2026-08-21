import Structured_Queries_Primitives

extension Table {

    public static func count(
        filter: ((TableColumns) -> some QueryExpression<Bool>)? = nil
    ) -> Select<Int, Self, ()> {
        Self.all
            .asSelect()
            .select { _ in
                .count(filter: filter?(columns))
            }
    }
}
