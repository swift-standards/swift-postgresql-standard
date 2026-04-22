import Tests_Inline_Snapshot

/// Compatibility shim mapping Point-Free's `assertInlineSnapshot(of:as:...)` to the ecosystem's `snapshot(as:)`.
@discardableResult
public func assertInlineSnapshot<Value>(
    of value: @autoclosure () -> Value,
    as strategy: Test.Snapshot.Strategy<Value, String>,
    message: String? = nil,
    matches expected: (() -> String)? = nil,
    fileID: String = #fileID,
    file filePath: String = #filePath,
    function: String = #function,
    line: Int = #line,
    column: Int = #column
) -> Test.Expectation {
    snapshot(
        as: strategy,
        { value() },
        matches: expected,
        fileID: fileID,
        filePath: filePath,
        line: line,
        column: column,
        function: function
    )
}
