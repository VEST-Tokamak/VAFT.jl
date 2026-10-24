# Contributing to VAFT.jl

## Development setup

```bash
git clone https://github.com/VEST-Tokamak/VAFT.jl
cd VAFT.jl
julia --project=. -e 'using Pkg; Pkg.instantiate()'
julia --project=. -e 'using Pkg; Pkg.test()'
```

`Manifest.toml` is not committed; compatibility is expressed in `Project.toml` `[compat]`.

## Scope and ownership

- **Data model:** IMASdd.jl owns IDS definitions, serialization and time
  interpolation. Do not reimplement them here. If IMASdd.jl is missing something or
  has a bug, prefer an upstream issue or PR; a local workaround must say which
  upstream version it targets and how to tell when it can be removed.
- **Scientific algorithms:** existing Python VAFT implementations
  (`vaft.formula`, `vaft.process`, `vaft.code`, ...) remain authoritative. A Julia
  implementation of the same algorithm needs an explicit reason (interoperability,
  benchmarking or validation) stated in the PR. New Julia-native capabilities are
  welcome when they bring something Julia does well (solvers, AD, performance).
- **Dependencies:** add a package only when a feature needs it. Optional
  integrations (Python, plotting) belong in package extensions under `ext/`.

## Code conventions

- Follow the [Julia style guide](https://docs.julialang.org/en/v1/manual/style-guide/).
- Public functions get docstrings and tests.
- Throw Julia exceptions with actionable messages; never silently convert units or
  coordinate conventions.

## Tests

- Add tests under `test/` and include them from `test/runtests.jl`.
- Fixtures must be small and reproducible. Generate them with IMASdd.jl writers from
  a script committed next to them (see `test/fixtures/make_fixtures.jl`).
- The core suite must not need Python, a network connection, or a VEST database.

## Pull requests

- Update `CHANGELOG.md` under `[Unreleased]`.
- CI (Julia 1.11, Linux) must pass.
