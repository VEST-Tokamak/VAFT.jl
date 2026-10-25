# VAFT.jl

Julia-native interface to the Versatile Analysis Framework for Tokamak
([VAFT](https://github.com/VEST-Tokamak/vaft)).

VAFT.jl uses [IMASdd.jl](https://github.com/ProjectTorreyPines/IMASdd.jl) as its
IMAS-compatible data model. Data you load are ordinary IMASdd.jl structures, so the
whole IMASdd.jl API (time interpolation, expressions, units, coordinates,
serialization) works on them directly. VAFT.jl does not define its own IDS schema or
file serializers, and it does not require Python.

> Status: initial release (0.1.0, unregistered). The API is small and may change.

## Installation

Requires Julia 1.11 or newer.

```julia
using Pkg
Pkg.add(url="https://github.com/VEST-Tokamak/VAFT.jl")
```

See [docs/installation.md](docs/installation.md) for development setup.

## Quick start

```julia
using VAFT

VAFT.doctor()                      # versions and supported formats

dd = load_imas("example.h5")       # or .json; returns an IMASdd.dd

eq = dd.equilibrium                # native IMASdd.jl IDS access
if !isempty(eq.time_slice)
    ip = eq.time_slice[1].global_quantities.ip
end
```

A runnable version is in [examples/getting_started.jl](examples/getting_started.jl), and a
step-by-step tutorial in [notebooks/getting_started.ipynb](notebooks/getting_started.ipynb).

To write data, use IMASdd.jl directly, e.g. `VAFT.IMASdd.imas2h5i(dd, "out.h5")`.

## Supported formats

| `format` | Description | Extensions (auto-detect) | IMASdd.jl reader |
|---|---|---|---|
| `:json` | OMAS/IMAS JSON | `.json` | `json2imas` |
| `:h5i` | IMAS tensorized HDF5 | `.h5`, `.hdf5` | `h5i2imas` |
| `:hdf` | OMAS hierarchical HDF5 | `.h5`, `.hdf5` | `hdf2imas` |

For HDF5 files, `load_imas` inspects the file to tell tensorized from hierarchical
layout. Pass `format=` explicitly for other extensions. Extra keyword arguments go to
the IMASdd.jl reader unchanged. Values, units and coordinate conventions are returned
as stored.

Errors:
- missing file: `ArgumentError`
- unknown or unsupported format (including OMAS NetCDF `.nc`): `VAFT.UnsupportedFormatError`
- reader failure: `VAFT.IMASLoadError`, with the original exception in `.cause`

## Known limitations

- Local files only. No IMAS-Core / remote Data Entry, HSDS, or MDSplus access.
- One IMASdd.jl `dd` per file. VAFT's occurrence-aware `DD`/`DDView`/`DDCollection`
  abstractions are not implemented yet (see [docs/architecture.md](docs/architecture.md)).
- IMASdd.jl 8.6.2 `h5i2imas` fails on fields that are set in only some elements of an
  array of structures (for example an uncertainty on one time slice but not the
  others). This surfaces as `IMASLoadError`; JSON and hierarchical HDF5 are not affected.
- Python VAFT interoperability is not yet available
  (see [docs/interoperability.md](docs/interoperability.md)).
- Tested on Julia 1.11 (CI) and 1.12 with IMASdd.jl 8.6.

## Documentation

- [Tutorial notebook](notebooks/getting_started.ipynb)
- [Architecture](docs/architecture.md)
- [Installation](docs/installation.md)
- [Interoperability with Python VAFT](docs/interoperability.md)
- [Contributing](CONTRIBUTING.md)

## License

Apache-2.0, see [LICENSE](LICENSE). IMASdd.jl is also Apache-2.0 and is used as a
dependency, not vendored.
