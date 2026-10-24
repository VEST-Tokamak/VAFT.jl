# Getting started with VAFT.jl
#
#     julia --project=. examples/getting_started.jl [path/to/file.{json,h5}]
#
# Without an argument this reads the small synthetic fixture shipped with the tests.

using VAFT

VAFT.doctor()

path = isempty(ARGS) ? joinpath(@__DIR__, "..", "test", "fixtures", "equilibrium_small.json") : ARGS[1]
dd = VAFT.load_imas(path)

# `dd` is a native IMASdd.jl structure: use ordinary IDS field access and indexing.
eq = dd.equilibrium
println("\nequilibrium.time = ", eq.time)
if !isempty(eq.time_slice)
    gq = eq.time_slice[1].global_quantities
    println("time_slice[1].global_quantities.ip = ", gq.ip, " ", VAFT.IMASdd.units(gq, :ip))
end
