using PerformanceTestTools
using PerformanceTestTools._Testing: XFailTestSet
using Test

@testset "expected pass" begin
    PerformanceTestTools.@include("__test_ir.jl")
    PerformanceTestTools.@include_foreach(
        "__test_a_eq_b.jl",
        [["A" => "1", "B" => "1"], ["A" => "2", "B" => "2", `--compile=min`]],
    )
    PerformanceTestTools.@include_foreach(
        "__test_a_eq_b.jl",
        [["A" => "1", "B" => "1"], ["A" => "2", "B" => "2", `--compile=min`]],
        parallel = false,
    )
end

@testset "expected failures" begin
    @info "=== Starting xfail tests ==="
    @testset XFailTestSet "only envs" begin
        PerformanceTestTools.@include_foreach(
            "__test_a_eq_b.jl",
            [["A" => "1", "B" => "2"]],
        )
    end
    @testset XFailTestSet "envs and opts" begin
        PerformanceTestTools.@include_foreach(
            "__test_a_eq_b.jl",
            [["A" => "1", "B" => "2", `--compile=min`]],
        )
    end
    @testset XFailTestSet "with in-process" begin
        withenv("A" => "1", "B" => "2") do
            PerformanceTestTools.@include_foreach(
                "__test_a_eq_b.jl",
                [nothing, [`--compile=min`]],
            )
        end
    end
    @info "=== Finished xfail tests ==="
end
