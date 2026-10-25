# Changelog

All notable changes to VAFT.jl are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses
[Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- Julia package `VAFT` with IMASdd.jl as its IMAS data model and I/O layer.
- `load_imas(path; format=:auto, kw...)` for local JSON, IMAS tensorized HDF5 (h5i)
  and OMAS hierarchical HDF5 files, returning native IMASdd.jl objects.
- `UnsupportedFormatError` and `IMASLoadError` for clear failure reporting.
- `doctor()` environment report.
- Getting-started tutorial notebook (`notebooks/getting_started.ipynb`).
- Unit and file round-trip tests with a small synthetic fixture; GitHub Actions CI on Julia 1.11.
- Documentation of architecture, installation and future Python interoperability.
