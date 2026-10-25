# Notebooks

| Notebook | What it covers |
|---|---|
| [getting_started.ipynb](getting_started.ipynb) | `doctor`, `load_imas`, exploring IDS data with units and uncertainties, time-based access, writing and reading back, errors |

## Running

The notebooks need a Julia Jupyter kernel from [IJulia.jl](https://github.com/JuliaLang/IJulia.jl).
Install it in your global Julia environment, not in the VAFT.jl project:

```julia
using Pkg
Pkg.add("IJulia")
```

Then start Jupyter from the repository and pick the Julia kernel:

```bash
jupyter lab notebooks/getting_started.ipynb
```

The default IJulia kernel starts with `--project=@.`, so a notebook opened inside the
repository uses the VAFT.jl project. Run `Pkg.instantiate()` there once first (see
[docs/installation.md](../docs/installation.md)).

Notebooks are committed with their outputs so they can be read on GitHub without running them.
