import Foundation
import Structured_Queries

public enum Subquery {}

public typealias SubqueryAny<Value: QueryBindable> = Subquery.`Any`<Value>

public typealias SubqueryAll<Value: QueryBindable> = Subquery.`All`<Value>

public typealias SubquerySome<Value: QueryBindable> = Subquery.`Some`<Value>
