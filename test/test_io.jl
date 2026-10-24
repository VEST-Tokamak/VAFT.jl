const FIXTURE_JSON = joinpath(@__DIR__, "fixtures", "equilibrium_small.json")

function check_sample(dd)
    @test dd isa IMASdd.dd
    eq = dd.equilibrium
    @test eq.ids_properties.homogeneous_time == 1
    @test eq.ids_properties.comment == "VAFT.jl test fixture"
    @test eq.time == [0.1, 0.2]
    @test length(eq.time_slice) == 2
    @test eq.time_slice[2].time == 0.2
    @test eq.time_slice[1].global_quantities.ip == -1.0e5
    @test eq.time_slice[2].global_quantities.ip == -2.0e5
    p = eq.time_slice[2].profiles_1d.pressure
    @test p isa Vector{Float64}
    @test size(p) == (5,)
    @test p == [2000.0, 1500.0, 1000.0, 500.0, 0.0]
    @test eq.time_slice[2].profiles_1d.psi == collect(range(0.0, 1.0; length=5))
    # Units come from the data dictionary and must be untouched.
    @test IMASdd.units(eq.time_slice[1].global_quantities, :ip) == "A"
    @test IMASdd.units(eq.time_slice[1].profiles_1d, :pressure) == "Pa"
    @test eq.time_slice[1].global_quantities.ip_σ == 1.0e3
    @test eq.time_slice[2].global_quantities.ip_σ == 2.0e3
end

@testset "committed JSON fixture" begin
    dd = load_imas(FIXTURE_JSON)
    check_sample(dd)
    @test load_imas(FIXTURE_JSON; format=:json).equilibrium.time == [0.1, 0.2]
end

@testset "round trip via IMASdd writers" begin
    dir = mktempdir()
    src = sample_dd()
    cases = [
        (IMASdd.imas2json, "dd.json", :json),
        (IMASdd.imas2hdf, "dd_hdf.h5", :hdf),
        (IMASdd.imas2h5i, "dd_h5i.h5", :h5i),
        (IMASdd.imas2hdf, "dd_hdf.hdf5", :hdf),
        (IMASdd.imas2h5i, "dd_h5i.hdf5", :h5i),
    ]
    for (writer, name, fmt) in cases
        @testset "$name" begin
            path = joinpath(dir, name)
            writer(src, path)
            @test VAFT._detect_format(path) === fmt
            check_sample(load_imas(path))
            check_sample(load_imas(path; format=fmt))
        end
    end
    # Explicit format overrides the extension.
    renamed = joinpath(dir, "dd.data")
    cp(joinpath(dir, "dd.json"), renamed)
    check_sample(load_imas(renamed; format=:json))
end

@testset "known IMASdd limitation: sparse fields in h5i" begin
    # IMASdd 8.6.2 h5i2imas throws a BoundsError when a field is set in only some
    # elements of an array of structures. When this starts passing upstream, turn it
    # into a regular test and drop the workaround note in make_fixtures.jl.
    dd = sample_dd()
    IMASdd.empty!(dd.equilibrium.time_slice[2].global_quantities, :ip_σ)
    path = joinpath(mktempdir(), "sparse.h5")
    IMASdd.imas2h5i(dd, path)
    loaded = try load_imas(path) catch e; e end
    @test_broken loaded isa IMASdd.dd
    @test loaded isa IMASdd.dd || loaded isa VAFT.IMASLoadError
end

@testset "upstream OMAS sample" begin
    sample = joinpath(pkgdir(IMASdd), "sample", "omas_sample.h5")
    if isfile(sample)
        dd = load_imas(sample)
        @test dd isa IMASdd.dd
        @test !isempty(dd.equilibrium.time_slice)
    else
        @test_skip isfile(sample)
    end
end

@testset "errors" begin
    dir = mktempdir()
    @test_throws ArgumentError load_imas(joinpath(dir, "missing.json"))

    txt = joinpath(dir, "data.txt")
    write(txt, "not imas")
    err = try load_imas(txt) catch e; e end
    @test err isa VAFT.UnsupportedFormatError
    @test err.format === nothing
    @test occursin("Supported formats", sprint(showerror, err))

    nc = joinpath(dir, "data.nc")
    write(nc, "")
    @test_throws VAFT.UnsupportedFormatError load_imas(nc)
    @test_throws VAFT.UnsupportedFormatError load_imas(FIXTURE_JSON; format=:netcdf)

    bad = joinpath(dir, "broken.json")
    write(bad, "{ this is not json")
    err = try load_imas(bad) catch e; e end
    @test err isa VAFT.IMASLoadError
    @test err.format === :json
    @test err.path == bad
    @test occursin("broken.json", sprint(showerror, err))

    badh5 = joinpath(dir, "broken.h5")
    write(badh5, "not hdf5")
    @test_throws Exception load_imas(badh5)
end
