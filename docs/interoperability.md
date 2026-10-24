# Interoperability with Python VAFT

## Principle

Share scientific contracts, not necessarily implementation languages.

The Python VAFT package remains the authoritative implementation of its existing
capabilities (`vaft.formula`, `vaft.process`, `vaft.code`, `vaft.validation`, and the
workflows built on them). VAFT.jl should call into those implementations when it needs
them rather than maintain parallel copies. A Julia reimplementation of an existing
algorithm needs an explicit interoperability, benchmarking or validation requirement.

New capabilities can be Julia-native where Julia brings a real advantage: native
solvers, multiple-dispatch algorithms, automatic differentiation, integration with the
Julia scientific ecosystem, or performance. Each such capability has one owner
language.

## Data exchange today

Both packages read and write the same IMAS file formats, so files are the current
exchange path:

- Python VAFT / OMAS writes JSON or HDF5 → `VAFT.load_imas` reads it.
- `VAFT.IMASdd.imas2json` / `imas2hdf` / `imas2h5i` write files Python can read.

No Python installation is involved.

## Planned: PythonCall package extension

Python access will be an optional
[package extension](https://pkgdocs.julialang.org/v1/creating-packages/#Conditional-loading-of-code-in-packages-(Extensions)),
loaded only when the user also loads PythonCall.jl:

```toml
# Project.toml (future)
[weakdeps]
PythonCall = "6099a3de-0909-46bc-b1f4-468b9a2dfc0d"

[extensions]
VAFTPythonCallExt = "PythonCall"
```

```text
ext/
└── VAFTPythonCallExt.jl
```

Requirements:

- `using VAFT` and all IMAS file operations keep working without Python.
- The core test suite never needs Python; extension tests run in a separate CI job.
- Conversion between IMASdd.jl structures and OMAS ODS objects goes through a defined
  contract (paths, array ordering, time coordinates, units, COCOS), not ad hoc copies.
- `VAFT.doctor()` reports whether the extension is available.

## Planned: cross-language reference tests

Using an existing VAFT reference dataset (preferably VEST shot 39915), compare the
same data read or computed by both packages:

- selected numerical values
- array shape and dimension ordering (Julia is column-major, NumPy row-major by default)
- time coordinates
- physical units
- COCOS convention, where applicable
- provenance metadata
- missing-value and uncertainty conventions

These tests must report differences in *representation* (layout, ordering, empty vs
missing) separately from differences in *scientific meaning*. They are opt-in and do
not require a live VEST database for the core suite.
