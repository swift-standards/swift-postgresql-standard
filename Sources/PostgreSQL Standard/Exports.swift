@_exported import Structured_Queries_Primitives
// Foundation's `Date`, `UUID`, `Data`, `URL` and `Decimal` conformed to
// `QueryBindable` in the L1 core until it went Foundation-free; the
// conformances now live in this opt-in integration target. Re-exporting keeps
// them visible to every consumer of `PostgreSQL Standard`, so this package's
// own API is unchanged by the L1 redesign.
@_exported import Structured_Queries_Primitives_Foundation_Integration
