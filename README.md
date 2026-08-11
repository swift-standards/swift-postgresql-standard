# PostgreSQL Standard

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Typed encodings of PostgreSQL's SQL surface in Swift — functions, `CAST` expressions, and table conformances expressed against the institute's structured-query primitives, so queries are built and checked at the type level rather than assembled as strings.

## Key Features

- **Typed functions** — PostgreSQL functions modelled as Swift values, including a dedicated namespace for functions whose names would otherwise collide with the Swift standard library.
- **`CAST` expressions** — a protocol for types usable in `CAST` expressions, keeping conversions explicit and type-checked.
- **Table conformances** — integrates with the structured-query `Table` protocol so schema definitions drive query construction.

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/swift-standards/swift-postgresql-standard.git", branch: "main")
]
```

Add the product to your target:

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "PostgreSQL Standard", package: "swift-postgresql-standard")
    ]
)
```

Applications that use Foundation-backed query values such as `Date`, `UUID`,
`Data`, `URL`, or `Decimal` should depend on and import
`PostgreSQL Standard Foundation Integration` instead. That leaf product
re-exports the Foundation-free core.

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
