public import Foundation
import PostgreSQL_Standard
import PostgreSQL_Standard_Macros
import PostgreSQL_Standard_Test_Support
import Testing

extension SnapshotTests {
    @Suite("JSONB") struct JSONB {}
}

@Table("test_users")
struct TestUser {
    let id: UUID
    let name: String

    @Column(as: Foundation.Data.self)
    let settings: Foundation.Data

    @Column(as: Foundation.Data.self)
    let metadata: Foundation.Data

    @Column(as: Foundation.Data?.self)
    let preferences: Foundation.Data?

    @Column(as: Foundation.Data.self)
    let tags: Foundation.Data
}
