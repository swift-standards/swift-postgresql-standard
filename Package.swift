// swift-tools-version: 6.3.3

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "swift-postgresql-standard",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(
            name: "PostgreSQL Standard",
            targets: ["PostgreSQL Standard"]
        ),
        .library(
            name: "PostgreSQL Standard Test Support",
            targets: ["PostgreSQL Standard Test Support"]
        ),
        // "PostgreSQL Standard Macros" is not vended explicitly: SwiftPM
        // auto-vends an implicit product for .macro targets on current
        // tools, which the nested Tests/Testing package consumes
        // cross-package (macros cannot depend on a swift-macro-testing test
        // dep in this manifest per [INST-TEST-001]). An explicit .library
        // product of the same name duplicated that implicit product.
    ],
    traits: [
        .trait(
            name: "SQLValidation",
            description: "Enable SQL syntax validation against PostgreSQL using postgres-nio."
        ),
    ],
    dependencies: [
        // L1
        .package(url: "https://github.com/swift-primitives/swift-structured-queries-primitives.git", branch: "main"),

        // Remote
        .package(url: "https://github.com/swiftlang/swift-syntax.git", "602.0.0"..<"603.0.0"),
        .package(url: "https://github.com/vapor/postgres-nio.git", from: "1.22.0"),

        // Ecosystem (test support + tests)
        .package(url: "https://github.com/swift-foundations/swift-tests.git", branch: "main"),
    ],
    targets: [
        // MARK: - PostgreSQL Standard

        .target(
            name: "PostgreSQL Standard",
            dependencies: [
                "PostgreSQL Standard Macros",
                .product(name: "Structured Queries Primitives", package: "swift-structured-queries-primitives"),
                .product(name: "Structured Queries Primitives Support", package: "swift-structured-queries-primitives"),
            ]
        ),

        // MARK: - Macros

        .macro(
            name: "PostgreSQL Standard Macros",
            dependencies: [
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
            ],
            exclude: ["Symbolic Links/README.md"]
        ),

        // MARK: - Test Support

        .target(
            name: "PostgreSQL Standard Test Support",
            dependencies: [
                "PostgreSQL Standard",
                .product(name: "Tests Inline Snapshot", package: "swift-tests"),
                .product(name: "PostgresNIO", package: "postgres-nio",
                         condition: .when(traits: ["SQLValidation"])),
            ],
            path: "Tests/Support"
        ),

        // MARK: - Tests

        .testTarget(
            name: "PostgreSQL Standard Tests",
            dependencies: [
                "PostgreSQL Standard",
                "PostgreSQL Standard Test Support",
                .product(name: "Tests Inline Snapshot", package: "swift-tests"),
            ]
        ),

        .testTarget(
            name: "README Examples Tests",
            dependencies: [
                "PostgreSQL Standard",
                "PostgreSQL Standard Test Support",
                .product(name: "Tests Inline Snapshot", package: "swift-tests"),
                .product(name: "Tests Apple Testing Bridge", package: "swift-tests"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
