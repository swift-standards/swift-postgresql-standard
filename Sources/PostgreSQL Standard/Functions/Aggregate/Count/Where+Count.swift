import Structured_Queries_Primitives

extension Where {

    public func count(
        filter: ((From.TableColumns) -> some QueryExpression<Bool>)? = nil
    ) -> Select<Int, From, ()> {
        let filter = filter?(From.columns)
        return asSelect().select { _ in .count(filter: filter) }
    }
}
