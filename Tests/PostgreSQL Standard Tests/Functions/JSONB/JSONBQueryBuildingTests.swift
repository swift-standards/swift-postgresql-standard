import Byte
import Foundation
import PostgreSQL_Standard
import PostgreSQL_Standard_Macros
import PostgreSQL_Standard_Test_Support
import Testing

extension SnapshotTests.JSONB {
    @Suite("Query Building") struct QueryBuildingTests {

        @Test
        func `JSONB type alias exists`() {

            let _: [String].JSONB.Type = [String].JSONB.self
            let _: [Int].JSONB.Type = [Int].JSONB.self

            let _: [String: String].JSONB.Type = [String: String].JSONB.self
            let _: [String: Int].JSONB.Type = [String: Int].JSONB.self

            #expect(Bool(true))
        }

        @Test
        func `JSONB QueryBinding`() {

            let arrayRep = [String].JSONB(queryOutput: ["feature1", "feature2"])
            let arrayBinding = arrayRep.queryBinding

            switch arrayBinding {
            case .jsonb(let data):
                let decoded = String(decoding: data.map(\.underlying), as: UTF8.self)
                #expect(decoded.contains("feature1"))
                #expect(decoded.contains("feature2"))

            default:
                Issue.record("Expected .jsonb binding, got \(arrayBinding)")
            }

            let dictRep = [String: String].JSONB(queryOutput: ["key1": "value1", "key2": "value2"])
            let dictBinding = dictRep.queryBinding

            switch dictBinding {
            case .jsonb(let data):
                let decoded = String(decoding: data.map(\.underlying), as: UTF8.self)
                #expect(decoded.contains("key1"))
                #expect(decoded.contains("value1"))

            default:
                Issue.record("Expected .jsonb binding, got \(dictBinding)")
            }
        }

        @Test
        func `Table with JSONB columns generates INSERT statement`() {

            let insertStatement = TestTable.insert {
                TestTable(
                    id: 1,
                    features: ["feature1", "feature2"],
                    metadata: ["key": "value"]
                )
            }

            _ = insertStatement
        }

        @Test
        func `QueryFragment handles JSONB binding`() {

            let features = ["feature1", "feature2"]
            let jsonbRep = [String].JSONB(queryOutput: features)
            let binding = jsonbRep.queryBinding

            let fragment: QueryFragment = """
                    INSERT INTO test (data) VALUES (\(binding))
                """

            _ = fragment
        }
    }
}

@Table("test_jsonb")
private struct TestTable {
    let id: Int
    @Column(as: [String].JSONB.self)
    let features: [String]
    @Column(as: [String: String].JSONB.self)
    let metadata: [String: String]
}
