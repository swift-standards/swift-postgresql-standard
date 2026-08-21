import Foundation
import Structured_Queries_Primitives

public enum Subquery {}

public typealias SubqueryAny<Value: QueryBindable> = Subquery.`Any`<Value>

public typealias SubqueryAll<Value: QueryBindable> = Subquery.`All`<Value>

public typealias SubquerySome<Value: QueryBindable> = Subquery.`Some`<Value>
