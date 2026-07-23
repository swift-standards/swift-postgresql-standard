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
        .library(
            name: "PostgreSQL Standard Macros",
            targets: ["PostgreSQL Standard Macros"]
        ),
        // Exposed for the nested testing package (Tests/Package.swift) only.
        // NOTE: the product name MUST differ from the ".macro" target name
        // "PostgreSQL Standard Macros Implementation". SwiftPM auto-vends an
        // implicit product for the .macro target under that exact name; an
        // explicit same-named .library collides with it ("ignoring duplicate
        // product ... (macro)"), SwiftPM drops the plugin product, and every
        // downstream @Table site fails "external macro ... could not be found".
        // The distinct "... Library" name lets the importable library product
        // and the macro plugin product coexist. The module the nested tests
        // import is unchanged (module name derives from the target, not the
        // product): `import PostgreSQL_Standard_Macros_Implementation`.
        .library(
            name: "PostgreSQL Standard Macros Implementation Library",
            targets: ["PostgreSQL Standard Macros Implementation"]
        ),
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
                .product(name: "Structured Queries Primitives", package: "swift-structured-queries-primitives"),
                .product(name: "Structured Queries Primitives Support", package: "swift-structured-queries-primitives"),
            ]
        ),

        // MARK: - Macros

        .target(
            name: "PostgreSQL Standard Macros",
            dependencies: [
                "PostgreSQL Standard",
                "PostgreSQL Standard Macros Implementation",
            ],
            path: "Sources/PostgreSQL Standard Macro Declarations"
        ),
        .macro(
            name: "PostgreSQL Standard Macros Implementation",
            dependencies: [
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
            ],
            path: "Sources/PostgreSQL Standard Macros",
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

        // "PostgreSQL Standard Macros Tests" lives in the nested testing package
        // (Tests/Package.swift) per [INST-TEST-001]: pointfreeco test-only deps
        // never enter this manifest.

        .testTarget(
            name: "PostgreSQL Standard Tests",
            dependencies: [
                "PostgreSQL Standard",
                "PostgreSQL Standard Macros",
                "PostgreSQL Standard Test Support",
                .product(name: "Tests Inline Snapshot", package: "swift-tests"),
            ],
            path: "Tests/PostgreSQL Standard Tests"
        ),

        .testTarget(
            name: "README Examples Tests",
            dependencies: [
                "PostgreSQL Standard",
                "PostgreSQL Standard Macros",
                "PostgreSQL Standard Test Support",
                .product(name: "Tests Inline Snapshot", package: "swift-tests"),
                .product(name: "Tests Apple Testing Bridge", package: "swift-tests"),
            ],
            path: "Tests/README Examples Tests"
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
