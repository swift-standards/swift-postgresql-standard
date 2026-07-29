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
        // The DSL -> execution bridge. Opt-in: a consumer that only builds statements never
        // resolves swift-sql, and a consumer of the engine-free `SQL` interface never resolves
        // this dialect. It lives here rather than in swift-sql because a generic, engine-free
        // execution interface must not depend on a dialect — with the bridge moved out, the
        // `SQL` core rests on L1 primitives alone and `swift-postgresql-standard -> swift-sql`
        // is a downward edge.
        .library(
            name: "PostgreSQL Standard SQL Integration",
            targets: ["PostgreSQL Standard SQL Integration"]
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
        .package(url: "https://github.com/swift-primitives/swift-byte-primitives.git", branch: "main"),

        // Remote
        .package(url: "https://github.com/swiftlang/swift-syntax.git", "602.0.0"..<"603.0.0"),
        .package(url: "https://github.com/vapor/postgres-nio.git", from: "1.22.0"),

        // Ecosystem (test support + tests)
        .package(url: "https://github.com/swift-foundations/swift-tests.git", branch: "main"),

        // L3 engine-free execution interface, consumed only by the SQL Integration target.
        .package(url: "https://github.com/swift-foundations/swift-sql.git", branch: "main"),
    ],
    targets: [
        // MARK: - PostgreSQL Standard

        .target(
            name: "PostgreSQL Standard",
            dependencies: [
                .product(name: "Structured Queries Primitives", package: "swift-structured-queries-primitives"),
                .product(name: "Structured Queries Primitives Support", package: "swift-structured-queries-primitives"),
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
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
            ],
            path: "Sources/PostgreSQL Standard Macros",
            exclude: ["Symbolic Links/README.md"]
        ),

        // MARK: - Test Support

        // MARK: - SQL Integration (the DSL -> execution bridge)

        .target(
            name: "PostgreSQL Standard SQL Integration",
            dependencies: [
                "PostgreSQL Standard",
                .product(name: "SQL", package: "swift-sql"),
                .product(name: "Byte Primitives", package: "swift-byte-primitives"),
            ],
            path: "Sources/PostgreSQL Standard SQL Integration"
        ),

        .testTarget(
            name: "PostgreSQL Standard SQL Integration Tests",
            dependencies: [
                "PostgreSQL Standard SQL Integration",
                "PostgreSQL Standard",
                .product(name: "SQL", package: "swift-sql"),
                // The scripted `SQL.Database` / `SQL.Row` doubles the fetch tests run against.
                .product(name: "SQL Test Support", package: "swift-sql"),
                .product(name: "Byte Primitives", package: "swift-byte-primitives"),
                // `@Table` is a macro attribute, so it is not reachable through the runtime
                // library's `@_exported import` and the fixtures need the macro product directly.
                "PostgreSQL Standard Macros",
            ],
            path: "Tests/PostgreSQL Standard SQL Integration Tests"
        ),

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
                // `QueryBinding`'s blob/jsonb payloads are `[Byte]` since the L1
                // Foundation drain; the binding tests read those bytes back.
                .product(name: "Byte Primitives", package: "swift-byte-primitives"),
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
