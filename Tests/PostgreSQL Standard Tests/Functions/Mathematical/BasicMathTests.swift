import Foundation
import Tests_Inline_Snapshot
import PostgreSQL_Standard
import PostgreSQL_Standard_Test_Support
import Testing

extension SnapshotTests.PostgresMath {
    @Suite("Basic Math Functions") struct BasicMathTests {

        // MARK: - .min() and .max() Disambiguation Tests

        @Test
        func `Swift stdlib .min() vs SQL .min() - disambiguation`() async {
            // This test demonstrates that both .min() methods coexist peacefully:
            // 1. Swift's stdlib .min() for regular Swift collections (preferred via @_disfavoredOverload)
            // 2. SQL's .min() for QueryExpression types (PostgreSQL's least() function)

            // Swift stdlib .min() - used for regular Swift arrays
            let numbers = [5, 2, 8, 1, 9]
            let swiftMin = numbers.min()  // Calls Swift.Sequence.min()
            #expect(swiftMin == 1)

            // SQL .min() - generates PostgreSQL's least() in query
            await assertSQL(
                of: PriceItem.select { $0.price.min($0.comparePrice) }  // Calls QueryExpression.min()
            ) {
                """
                SELECT least("price_items"."price", "price_items"."comparePrice")
                FROM "price_items"
                """
            }
        }

        @Test
        func `Swift stdlib .max() vs SQL .max() - disambiguation`() async {
            // This test demonstrates that both .max() methods coexist peacefully:
            // 1. Swift's stdlib .max() for regular Swift collections (preferred via @_disfavoredOverload)
            // 2. SQL's .max() for QueryExpression types (PostgreSQL's greatest() function)

            // Swift stdlib .max() - used for regular Swift arrays
            let numbers = [5, 2, 8, 1, 9]
            let swiftMax = numbers.max()  // Calls Swift.Sequence.max()
            #expect(swiftMax == 9)

            // SQL .max() - generates PostgreSQL's greatest() in query
            await assertSQL(
                of: PriceItem.select { $0.price.max($0.comparePrice) }  // Calls QueryExpression.max()
            ) {
                """
                SELECT greatest("price_items"."price", "price_items"."comparePrice")
                FROM "price_items"
                """
            }
        }

        // MARK: - Basic Math Functions

        @Test func abs() async {
            await assertSQL(
                of: MathTransaction.select { $0.amount.abs() }
            ) {
                """
                SELECT abs("math_transactions"."amount")
                FROM "math_transactions"
                """
            }
        }

        @Test func ceil() async {
            await assertSQL(
                of: Measurement.select { $0.value.ceil() }
            ) {
                """
                SELECT ceil("measurements"."value")
                FROM "measurements"
                """
            }
        }

        @Test func ceiling() async {
            await assertSQL(
                of: Measurement.select { $0.value.ceiling() }
            ) {
                """
                SELECT ceiling("measurements"."value")
                FROM "measurements"
                """
            }
        }

        @Test func floor() async {
            await assertSQL(
                of: Measurement.select { $0.value.floor() }
            ) {
                """
                SELECT floor("measurements"."value")
                FROM "measurements"
                """
            }
        }

        @Test func round() async {
            await assertSQL(
                of: Measurement.select { $0.value.round() }
            ) {
                """
                SELECT round("measurements"."value")
                FROM "measurements"
                """
            }
        }

        @Test func roundWithDecimalPlaces() async {
            await assertSQL(
                of: PriceItem.select { $0.price.round(decimalPlaces: 2) }
            ) {
                """
                SELECT round("price_items"."price", 2)
                FROM "price_items"
                """
            }
        }

        @Test func trunc() async {
            await assertSQL(
                of: Measurement.select { $0.value.trunc() }
            ) {
                """
                SELECT trunc("measurements"."value")
                FROM "measurements"
                """
            }
        }

        @Test func truncWithDecimalPlaces() async {
            await assertSQL(
                of: PriceItem.select { $0.price.trunc(decimalPlaces: 2) }
            ) {
                """
                SELECT trunc("price_items"."price", 2)
                FROM "price_items"
                """
            }
        }

        @Test func sign() async {
            await assertSQL(
                of: MathTransaction.select { $0.amount.sign() }
            ) {
                """
                SELECT sign("math_transactions"."amount")
                FROM "math_transactions"
                """
            }
        }

        @Test func mod() async {
            await assertSQL(
                of: Number.select { $0.value.mod(10) }
            ) {
                """
                SELECT mod("numbers"."value", 10)
                FROM "numbers"
                """
            }
        }

        @Test func modWithExpression() async {
            await assertSQL(
                of: Number.select { $0.value.mod($0.divisor) }
            ) {
                """
                SELECT mod("numbers"."value", "numbers"."divisor")
                FROM "numbers"
                """
            }
        }

        @Test func div() async {
            await assertSQL(
                of: Number.select { $0.value.div(10) }
            ) {
                """
                SELECT div("numbers"."value", 10)
                FROM "numbers"
                """
            }
        }

        // MARK: - GCD and LCM

        @Test func gcd() async {
            await assertSQL(
                of: Number.select { $0.a.gcd($0.b) }
            ) {
                """
                SELECT gcd("numbers"."a", "numbers"."b")
                FROM "numbers"
                """
            }
        }

        @Test func lcm() async {
            await assertSQL(
                of: Number.select { $0.a.lcm($0.b) }
            ) {
                """
                SELECT lcm("numbers"."a", "numbers"."b")
                FROM "numbers"
                """
            }
        }

        // MARK: - Min/Max Functions

        @Test func minWithValue() async {
            await assertSQL(
                of: PriceItem.select { $0.price.min(100) }
            ) {
                """
                SELECT least("price_items"."price", 100.0)
                FROM "price_items"
                """
            }
        }

        @Test func minWithExpression() async {
            await assertSQL(
                of: PriceItem.select { $0.price.min($0.comparePrice) }
            ) {
                """
                SELECT least("price_items"."price", "price_items"."comparePrice")
                FROM "price_items"
                """
            }
        }

        @Test func maxWithValue() async {
            await assertSQL(
                of: PriceItem.select { $0.price.max(100) }
            ) {
                """
                SELECT greatest("price_items"."price", 100.0)
                FROM "price_items"
                """
            }
        }

        @Test func maxWithExpression() async {
            await assertSQL(
                of: PriceItem.select { $0.price.max($0.comparePrice) }
            ) {
                """
                SELECT greatest("price_items"."price", "price_items"."comparePrice")
                FROM "price_items"
                """
            }
        }

        // MARK: - Real-World Use Cases

        @Test
        func `Calculate price with 10% discount, minimum $5`() async {
            // Real-world: Apply discount but ensure minimum price
            await assertSQL(
                of: PriceItem.select { ($0.id, ($0.price * 0.9).max(5.0)) }
            ) {
                """
                SELECT "price_items"."id", greatest(("price_items"."price") * (0.9), 5.0)
                FROM "price_items"
                """
            }
        }

        @Test
        func `Cap maximum price increase`() async {
            // Real-world: Increase price by 20% but cap at compare price
            await assertSQL(
                of: PriceItem.update {
                    $0.price = ($0.price * 1.2).min($0.comparePrice)
                }
            ) {
                """
                UPDATE "price_items"
                SET "price" = least(("price_items"."price") * (1.2), "price_items"."comparePrice")
                """
            }
        }

        @Test
        func `Round currency to 2 decimal places`() async {
            // Real-world: Financial calculations need precise rounding
            await assertSQL(
                of: PriceItem.select { $0.price.round(decimalPlaces: 2) }
            ) {
                """
                SELECT round("price_items"."price", 2)
                FROM "price_items"
                """
            }
        }

        @Test
        func `Determine transaction type by sign`() async {
            // Real-world: Classify transactions as debit/credit by sign
            await assertSQL(
                of: MathTransaction.select { ($0.id, $0.amount.sign()) }
            ) {
                """
                SELECT "math_transactions"."id", sign("math_transactions"."amount")
                FROM "math_transactions"
                """
            }
        }

        @Test
        func `Calculate absolute difference`() async {
            // Real-world: Find price variance regardless of direction
            await assertSQL(
                of: PriceItem.select { ($0.price - $0.comparePrice).abs() }
            ) {
                """
                SELECT abs(("price_items"."price") - ("price_items"."comparePrice"))
                FROM "price_items"
                """
            }
        }
    }
}

// MARK: - Test Models

@Table("price_items")
private struct PriceItem {
    let id: Int
    let name: String
    let price: Double
    let comparePrice: Double
}

@Table("math_transactions")
private struct MathTransaction {
    let id: Int
    let amount: Double
}

@Table
private struct Measurement {
    let id: Int
    let value: Double
}

@Table
private struct Number {
    let id: Int
    let value: Int
    let divisor: Int
    let a: Int
    let b: Int
}
