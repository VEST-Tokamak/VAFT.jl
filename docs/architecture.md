# Architecture

## Layers

```text
User code / research workflows
        │
        ▼
VAFT.jl            load_imas, doctor (this package)
        │          future: DD / DDView / DDCollection, Python bridge, Julia-native algorithms
        ▼
IMASdd.jl          IDS types, data dictionary, JSON/HDF5 I/O, time interpolation,
                   expressions, units, coordinates, uncertainties
        │
        ▼
Files              JSON, IMAS tensorized HDF5 (h5i), OMAS hierarchical HDF5
```

VAFT.jl adds behavior on top of IMASdd.jl; it does not wrap or re-type its objects.
`load_imas` returns the `IMASdd.dd` produced by the upstream reader, and everything
else is done with IMASdd.jl's API.

## What VAFT.jl does on top of IMASdd.jl today

`IMASdd.file2imas` already dispatches on file extension. `load_imas` adds:

- explicit `format=` selection, so files with nonstandard extensions can be read;
- `.hdf5` as well as `.h5`;
- tensorized/hierarchical HDF5 detection that also finds `&`-flattened datasets
  inside IDS groups. IMASdd.jl 8.6's `is_h5i` checks only the file's top level, so it
  misreports files written by `IMASdd.imas2h5i`, and `file2imas` then picks the wrong reader;
- typed errors (`UnsupportedFormatError`, `IMASLoadError`) instead of `file2imas`
  returning `nothing` for unknown extensions.

Once these are covered upstream, `load_imas` should shrink to a direct call.

## Relationship to VAFT's DD abstraction

Python VAFT is moving toward this data abstraction
([vaft#1127](https://github.com/VEST-Tokamak/vaft/issues/1127)):

```text
DDCollection  →  DD  →  DDView  →  selected IDS instances  →  IMAS data model
```

IMASdd.jl's `dd` sits at the bottom of that stack: it holds **one** instance of each
IDS. It is not the same thing as VAFT's occurrence-aware `DD`, which tracks multiple
stored occurrences of an IDS. Consequences for VAFT.jl:

- `load_imas` returns one `IMASdd.dd` per file and makes no claim about occurrences.
- A future `VAFT.DD` should hold IMASdd.jl objects, not replace them, and should not
  define a competing IDS schema.
- Occurrence identity should come from stored metadata such as
  `ids_properties.name` where present, not from a mandatory device-specific registry.
- `DDView` selections should be immutable and independent of the I/O backend, so the
  same view logic works for files, IMAS-Core, or HSDS once those adapters exist.

These abstractions are deferred until their semantics are settled on the Python side,
so both languages share one contract.

## Deferred work

- `DD`, `DDView`, `DDCollection` and multi-occurrence management
- IMAS-Core / remote Data Entry adapters, HSDS client and authentication
- PythonCall-based VAFT integration (see [interoperability.md](interoperability.md))
- Julia-native physics algorithms, plotting, Study/Run orchestration
- Registration in the Julia General registry
