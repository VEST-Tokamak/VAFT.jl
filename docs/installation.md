# Installation

## Requirements

- Julia 1.11 or newer ([juliaup](https://github.com/JuliaLang/juliaup) recommended).
- No Python, IMAS-Core, or database service is needed.

IMASdd.jl and HDF5.jl are installed automatically. HDF5.jl ships its own HDF5
library through `HDF5_jll`; a system HDF5 is not required.

## Install the package

VAFT.jl is not yet registered in the Julia General registry:

```julia
using Pkg
Pkg.add(url="https://github.com/VEST-Tokamak/VAFT.jl")
```

## Development install

```bash
git clone https://github.com/VEST-Tokamak/VAFT.jl
cd VAFT.jl
julia --project=. -e 'using Pkg; Pkg.instantiate()'
```

Or, from another environment:

```julia
using Pkg
Pkg.develop(path="/path/to/VAFT.jl")
```

The first `using VAFT` precompiles IMASdd.jl, which contains the full IMAS Data
Dictionary and takes several minutes. Later sessions load from the cache.

## Check the installation

```julia
using VAFT
VAFT.doctor()
```

`doctor` prints the Julia, VAFT.jl, IMASdd.jl and HDF5.jl versions and the supported
file formats. It does not install or modify anything.

## Run the tests

```bash
julia --project=. -e 'using Pkg; Pkg.test()'
```
