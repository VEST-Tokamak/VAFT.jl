# Regenerates the committed test fixtures with IMASdd.jl's own writers.
#
#     julia --project=. test/fixtures/make_fixtures.jl
#
# The data are synthetic and chosen only to exercise I/O; they are not a physical equilibrium.

using VAFT
const IMASdd = VAFT.IMASdd

"""
    sample_dd() -> IMASdd.dd

Small equilibrium IDS with two time slices, 1D profiles, metadata and uncertainties.
"""
function sample_dd()
    dd = IMASdd.dd()
    eq = dd.equilibrium
    eq.ids_properties.homogeneous_time = 1
    eq.ids_properties.comment = "VAFT.jl test fixture"
    eq.time = [0.1, 0.2]
    resize!(eq.time_slice, 2)
    for (k, t) in enumerate(eq.time)
        ts = eq.time_slice[k]
        ts.time = t
        ts.global_quantities.ip = -1.0e5 * k
        ts.profiles_1d.psi = collect(range(0.0, 1.0; length=5))
        ts.profiles_1d.pressure = collect(range(1.0e3, 0.0; length=5)) .* k
        # Filled in every slice: IMASdd 8.6 h5i2imas cannot read fields present in only
        # some elements of an array of structures (see test_io.jl).
        ts.global_quantities.ip_σ = 1.0e3 * k
    end
    return dd
end

if abspath(PROGRAM_FILE) == @__FILE__
    IMASdd.imas2json(sample_dd(), joinpath(@__DIR__, "equilibrium_small.json"); indent=1)
end
