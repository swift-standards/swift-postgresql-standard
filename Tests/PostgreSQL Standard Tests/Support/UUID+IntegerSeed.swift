import Foundation

extension UUID {
    /// Creates a deterministic UUID from an integer seed (test fixture idiom):
    /// `UUID(0)` == `00000000-0000-0000-0000-000000000000`.
    init(_ intValue: Int) {
        self.init(
            uuidString: "00000000-0000-0000-0000-\(String(format: "%012x", intValue))"
        )!
    }
}
