// swift-tools-version: 6.4

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "swift-postgresql-standard",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "PostgreSQL Standard",
            targets: ["PostgreSQL Standard"]
        ),
//        .library(
//            name: "PostgreSQL Standard Test Support",
//            targets: ["PostgreSQL Standard Test Support"]
//        ),
        .library(
            name: "PostgreSQL Standard Macros",
            targets: ["PostgreSQL Standard Macros"]
        ),
        // Exposed for the nested testing package (Tests/Package.swift) only.
        //
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
        //
        // NOTE: the implementations must live IN the .macro target, not in a
        // plain library it depends on. `#externalMacro(module:type:)` names one
        // module for two lookups: SwiftPM registers the plugin executable under
        // the .macro target's module, and SwiftCompilerPlugin then resolves the
        // type by exact `"\(module).\(type)"` match against `String(reflecting:)`
        // of each providing macro. Splitting the two apart makes those two names
        // disagree and no spelling of the declaration can satisfy both.
        .library(
            name: "PostgreSQL Standard Macros Implementation Library",
            targets: ["PostgreSQL Standard Macros Implementation"]
        ),
    ],
    traits: [
        .trait(
            name: "SQLValidation",
            description: "Enable SQL syntax validation against PostgreSQL using postgres-nio."
        )
    ],
    dependencies: [
        // L1
        .package(
            url: "https://github.com/swift-primitives/swift-structured-queries-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-byte-primitives.git",
            branch: "main"
        ),
//        .package(
//            url: "https://github.com/swift-primitives/swift-test-primitives.git",
//            branch: "main"
//        ),

        // Remote
        .package(url: "https://github.com/swiftlang/swift-syntax.git", "602.0.0"..<"603.0.0"),
//        .package(url: "https://github.com/vapor/postgres-nio.git", from: "1.22.0"),

        // Ecosystem (test support + tests)
//        .package(url: "https://github.com/swift-foundations/swift-tests.git", branch: "main"),
    ],
    targets: [
        // MARK: - PostgreSQL Standard

        .target(
            name: "PostgreSQL Standard",
            dependencies: [
                .product(
                    name: "Structured Queries Primitives",
                    package: "swift-structured-queries-primitives"
                ),
                .product(
                    name: "Structured Queries Primitives Support",
                    package: "swift-structured-queries-primitives"
                ),
                // This target's public surface binds Foundation's `Date`, `UUID`,
                // `Data`, `URL` and `Decimal` (see `Cast.swift`, `PostgresArray.swift`,
                // `Trigger.Function+Helpers.swift`). Those `QueryBindable`
                // conformances moved out of the L1 core into this opt-in
                // integration target when the core went Foundation-free, so the
                // dependency is what keeps this package's own API unchanged.
                .product(
                    name: "Structured Queries Primitives Foundation Integration",
                    package: "swift-structured-queries-primitives"
                ),
                .product(name: "Byte Primitives", package: "swift-byte-primitives"),
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
                .product(name: "SwiftBasicFormat", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            ],
            path: "Sources/PostgreSQL Standard Macros"
        ),

        // MARK: - Test Support

//        .target(
//            name: "PostgreSQL Standard Test Support",
//            dependencies: [
//                "PostgreSQL Standard",
//                .product(name: "Tests Inline Snapshot", package: "swift-tests"),
//                .product(
//                    name: "Test Snapshot Primitives",
//                    package: "swift-test-primitives"
//                ),
//                .product(
//                    name: "PostgresNIO",
//                    package: "postgres-nio",
//                    condition: .when(traits: ["SQLValidation"])
//                ),
//            ],
//            path: "Tests/Support"
//        ),

        // MARK: - Tests

        // "PostgreSQL Standard Macros Tests" lives in the nested testing package
        // (Tests/Package.swift) per [INST-TEST-001]: pointfreeco test-only deps
        // never enter this manifest.

//        .testTarget(
//            name: "PostgreSQL Standard Tests",
//            dependencies: [
//                "PostgreSQL Standard",
//                "PostgreSQL Standard Macros",
//                "PostgreSQL Standard Test Support",
//                .product(name: "Tests Inline Snapshot", package: "swift-tests"),
//                // `QueryBinding`'s blob/jsonb payloads are `[Byte]` since the L1
//                // Foundation drain; the binding tests read those bytes back.
//                .product(name: "Byte Primitives", package: "swift-byte-primitives"),
//            ],
//            path: "Tests/PostgreSQL Standard Tests"
//        ),
//
//        .testTarget(
//            name: "README Examples Tests",
//            dependencies: [
//                "PostgreSQL Standard",
//                "PostgreSQL Standard Macros",
//                "PostgreSQL Standard Test Support",
//                .product(name: "Tests Inline Snapshot", package: "swift-tests"),
//                .product(name: "Tests Apple Testing Bridge", package: "swift-tests"),
//            ],
//            path: "Tests/README Examples Tests"
//        ),
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
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
