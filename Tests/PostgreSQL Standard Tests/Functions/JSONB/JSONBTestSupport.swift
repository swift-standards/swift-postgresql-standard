public import Foundation
import PostgreSQL_Standard
import PostgreSQL_Standard_Test_Support
import Testing

// JSONB test namespace
extension SnapshotTests {
    @Suite("JSONB") struct JSONB {}
}

// Shared test table with JSONB columns
@Table("test_users")
struct TestUser {
    let id: UUID
    let name: String

    @Column(as: Foundation.Data.self)  // JSONB column
    let settings: Foundation.Data

    @Column(as: Foundation.Data.self)  // JSONB column
    let metadata: Foundation.Data

    @Column(as: Foundation.Data?.self)  // Optional JSONB column
    let preferences: Foundation.Data?

    @Column(as: Foundation.Data.self)  // JSONB array column
    let tags: Foundation.Data
}
