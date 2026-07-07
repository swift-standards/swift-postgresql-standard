# Symbolic Links

This directory contains vendored **copies** of shared source code from
`swift-structured-queries-primitives`'s `Sources/Structured Queries Primitives
Support`, used by the StructuredQueries macros.

These were formerly symbolic links to that directory. Cross-repo relative
symlinks broke every source-control/mirror checkout of this package:
consumers resolve package dependencies as git clones, and a git clone does
not carry the sibling `swift-primitives` checkout the symlink pointed at, so
the link dangled (surfacing downstream as, e.g., `'String' has no member
'lowerCamelCased'`). Vendoring real files avoids that failure mode at the
cost of a drift obligation: when the upstream `Structured Queries Primitives
Support` sources change, this copy must be re-synced by hand.

This remains a workaround until SwiftPM has native support for sharing code
between macros and targets.
