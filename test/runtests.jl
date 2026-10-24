using Test
using VAFT

const IMASdd = VAFT.IMASdd

include(joinpath(@__DIR__, "fixtures", "make_fixtures.jl"))

@testset "VAFT.jl" begin
    @testset "environment" include("test_environment.jl")
    @testset "io" include("test_io.jl")
end
