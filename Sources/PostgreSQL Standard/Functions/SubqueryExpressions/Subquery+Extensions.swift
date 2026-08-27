import Foundation
import Structured_Queries

extension QueryExpression where QueryValue: Comparable & QueryBindable {

    public func lessThanAny(
        _ subquery: some QueryExpression<[QueryValue]>
    ) -> some QueryExpression<
        Bool
    > {
        SQLQueryExpression(
            "(\(self.queryFragment) < ANY (\(subquery.queryFragment)))",
            as: Bool.self
        )
    }

    public func lessThanOrEqualToAny(
        _ subquery: some QueryExpression<[QueryValue]>
    )
        -> some QueryExpression<Bool>
    {
        SQLQueryExpression(
            "(\(self.queryFragment) <= ANY (\(subquery.queryFragment)))",
            as: Bool.self
        )
    }

    public func greaterThanAny(
        _ subquery: some QueryExpression<[QueryValue]>
    )
        -> some QueryExpression<Bool>
    {
        SQLQueryExpression(
            "(\(self.queryFragment) > ANY (\(subquery.queryFragment)))",
            as: Bool.self
        )
    }

    public func greaterThanOrEqualToAny(
        _ subquery: some QueryExpression<[QueryValue]>
    )
        -> some QueryExpression<Bool>
    {
        SQLQueryExpression(
            "(\(self.queryFragment) >= ANY (\(subquery.queryFragment)))",
            as: Bool.self
        )
    }

    public func lessThanAll(
        _ subquery: some QueryExpression<[QueryValue]>
    ) -> some QueryExpression<
        Bool
    > {
        SQLQueryExpression(
            "(\(self.queryFragment) < ALL (\(subquery.queryFragment)))",
            as: Bool.self
        )
    }

    public func lessThanOrEqualToAll(
        _ subquery: some QueryExpression<[QueryValue]>
    )
        -> some QueryExpression<Bool>
    {
        SQLQueryExpression(
            "(\(self.queryFragment) <= ALL (\(subquery.queryFragment)))",
            as: Bool.self
        )
    }

    public func greaterThanAll(
        _ subquery: some QueryExpression<[QueryValue]>
    )
        -> some QueryExpression<Bool>
    {
        SQLQueryExpression(
            "(\(self.queryFragment) > ALL (\(subquery.queryFragment)))",
            as: Bool.self
        )
    }

    public func greaterThanOrEqualToAll(
        _ subquery: some QueryExpression<[QueryValue]>
    )
        -> some QueryExpression<Bool>
    {
        SQLQueryExpression(
            "(\(self.queryFragment) >= ALL (\(subquery.queryFragment)))",
            as: Bool.self
        )
    }

    public func lessThanSome(
        _ subquery: some QueryExpression<[QueryValue]>
    )
        -> some QueryExpression<Bool>
    {
        SQLQueryExpression(
            "(\(self.queryFragment) < SOME (\(subquery.queryFragment)))",
            as: Bool.self
        )
    }

    public func greaterThanSome(
        _ subquery: some QueryExpression<[QueryValue]>
    )
        -> some QueryExpression<Bool>
    {
        SQLQueryExpression(
            "(\(self.queryFragment) > SOME (\(subquery.queryFragment)))",
            as: Bool.self
        )
    }
}

extension QueryExpression where QueryValue: Equatable & QueryBindable {

    public func equalsAny(
        _ subquery: some QueryExpression<[QueryValue]>
    ) -> some QueryExpression<
        Bool
    > {
        SQLQueryExpression(
            "(\(self.queryFragment) = ANY (\(subquery.queryFragment)))",
            as: Bool.self
        )
    }

    public func notEqualsAny(
        _ subquery: some QueryExpression<[QueryValue]>
    )
        -> some QueryExpression<Bool>
    {
        SQLQueryExpression(
            "(\(self.queryFragment) <> ANY (\(subquery.queryFragment)))",
            as: Bool.self
        )
    }

    public func equalsAll(
        _ subquery: some QueryExpression<[QueryValue]>
    ) -> some QueryExpression<
        Bool
    > {
        SQLQueryExpression(
            "(\(self.queryFragment) = ALL (\(subquery.queryFragment)))",
            as: Bool.self
        )
    }

    public func notEqualsAll(
        _ subquery: some QueryExpression<[QueryValue]>
    )
        -> some QueryExpression<Bool>
    {
        SQLQueryExpression(
            "(\(self.queryFragment) <> ALL (\(subquery.queryFragment)))",
            as: Bool.self
        )
    }
}

public func any<Value: QueryBindable, Q: QueryExpression>(_ subquery: Q) -> Subquery.`Any`<Value>
where Q.QueryValue == [Value] {
    Subquery.`Any`(subquery)
}

public func all<Value: QueryBindable, Q: QueryExpression>(_ subquery: Q) -> Subquery.`All`<Value>
where Q.QueryValue == [Value] {
    Subquery.`All`(subquery)
}

public func some<Value: QueryBindable, Q: QueryExpression>(_ subquery: Q) -> Subquery.`Some`<Value>
where Q.QueryValue == [Value] {
    Subquery.`Some`(subquery)
}
