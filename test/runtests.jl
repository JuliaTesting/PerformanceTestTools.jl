using PerformanceTestTools
using Test

@testset "PerformanceTestTools.jl" begin
    PerformanceTestTools.@include("__test_ir.jl")
end
