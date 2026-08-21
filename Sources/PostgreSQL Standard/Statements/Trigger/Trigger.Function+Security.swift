import Foundation

extension String {

    package func escapedForPostgreSQL() -> String {
        replacingOccurrences(of: "'", with: "''")
    }
}
