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

        .library(
            name: "PostgreSQL Standard Macros",
            targets: ["PostgreSQL Standard Macros"]
        ),

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

        .package(
            url: "https://github.com/swift-molecules/swift-structured-queries.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-byte.git",
            branch: "main"
        ),

        .package(url: "https://github.com/swiftlang/swift-syntax.git", "603.0.2"..<"604.0.0"),

    ],
    targets: [

        .target(
            name: "PostgreSQL Standard",
            dependencies: [
                .product(
                    name: "Structured Queries",
                    package: "swift-structured-queries"
                ),
                .product(
                    name: "Structured Queries Support",
                    package: "swift-structured-queries"
                ),

                .product(
                    name: "Structured Queries Foundation Integration",
                    package: "swift-structured-queries"
                ),
                .product(name: "Byte", package: "swift-byte"),
            ]
        ),

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
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
