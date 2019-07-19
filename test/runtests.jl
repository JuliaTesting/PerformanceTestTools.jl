using IRTest
using Test

@testset "IRTest.jl" begin
    IRTest.@include("__test_ir.jl")
end
