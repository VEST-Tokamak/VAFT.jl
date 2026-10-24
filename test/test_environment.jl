@testset "package loads without Python" begin
    loaded = Set(string(m) for m in values(Base.loaded_modules))
    @test "PythonCall" ∉ loaded
    @test "PyCall" ∉ loaded
end

@testset "public API" begin
    @test isdefined(VAFT, :load_imas)
    @test isdefined(VAFT, :doctor)
    @test :load_imas in names(VAFT)
    @test :doctor in names(VAFT)
    @test VAFT.supported_formats() == [:json, :h5i, :hdf]
end

@testset "IMASdd is the data model" begin
    @test pkgversion(IMASdd) >= v"8.5"
    @test VAFT.IMASdd === Base.require(Base.PkgId(Base.UUID("c5a45a97-b3f9-491c-b9a7-aa88c3bc0067"), "IMASdd"))
end

@testset "doctor" begin
    buf = IOBuffer()
    info = doctor(buf)
    out = String(take!(buf))
    @test info.julia == VERSION
    @test info.vaft == pkgversion(VAFT)
    @test info.imasdd == pkgversion(IMASdd)
    @test info.formats == VAFT.supported_formats()
    @test info.pythoncall_installed isa Bool
    @test occursin("IMASdd.jl : $(info.imasdd)", out)
    @test occursin("h5i2imas", out)
    # Reporting PythonCall must not load it.
    @test "PythonCall" ∉ Set(string(m) for m in values(Base.loaded_modules))
end
