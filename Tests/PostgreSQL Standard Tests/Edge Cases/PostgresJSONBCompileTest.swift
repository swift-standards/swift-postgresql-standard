import Foundation
import PostgreSQL_Standard
import PostgreSQL_Standard_Macros

struct CompileTest {

    typealias StringArrayJSONB = [String].JSONB
    typealias IntArrayJSONB = [Int].JSONB

    typealias StringDictJSONB = [String: String].JSONB
    typealias MixedDictJSONB = [String: Int].JSONB

    typealias OptionalArrayJSONB = [String].JSONB?
    typealias OptionalDictJSONB = [String: String].JSONB?

    @Table("test_table")
    struct TestTable {
        let id: Int

        @Column(as: [String].JSONB.self)
        let features: [String]

        @Column(as: [String: String].JSONB.self)
        let metadata: [String: String]

        @Column(as: [Int].JSONB.self)
        let numbers: [Int]

        @Column(as: [String: Int].JSONB.self)
        let counts: [String: Int]
    }
}
