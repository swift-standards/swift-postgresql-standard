// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "testing",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    dependencies: [
        .package(path: ".."),
        .package(url: "https://github.com/pointfreeco/swift-macro-testing.git", from: "0.6.3"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", exact: "1.18.9"),
        .package(url: "https://github.com/swift-foundations/swift-tests.git", branch: "main"),
    ],
    targets: [
        .testTarget(
            name: "PostgreSQL Standard Macros Tests",
            dependencies: [
                .product(
                    name: "PostgreSQL Standard Macros Implementation Library",
                    package: "swift-postgresql-standard"
                ),
                .product(name: "MacroTesting", package: "swift-macro-testing"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
                .product(name: "Tests Snapshot", package: "swift-tests"),
            ],
            path: "PostgreSQL Standard Macros Tests"
        )
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    ]

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem
}
