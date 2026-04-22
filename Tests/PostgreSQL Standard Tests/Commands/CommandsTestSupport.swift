import Foundation
import PostgreSQL_Standard
import PostgreSQL_Standard_Test_Support
import Testing

// Commands test namespace
extension SnapshotTests {
    @Suite("Commands") struct Commands {
        @Suite("Select") struct Select {}
    }
}
