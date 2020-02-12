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
        parallel = true,
    )
end

@testset "expected failures" begin
    @info "=== Starting xfail tests ==="
    @testset for parallel in [false, true]
        @testset XFailTestSet "only envs" begin
            PerformanceTestTools.@include_foreach(
                "__test_a_eq_b.jl",
                [["A" => "1", "B" => "2"]],
                parallel = parallel,
            )
        end
    end
    @testset XFailTestSet "envs and opts" begin
        PerformanceTestTools.@include_foreach(
            "__test_a_eq_b.jl",
            [["A" => "1", "B" => "2", `--compile=min`]],
            parallel = true,
        )
    end
    @testset XFailTestSet "with in-process" begin
        withenv("A" => "1", "B" => "2") do
            PerformanceTestTools.@include_foreach(
                "__test_a_eq_b.jl",
                [nothing, [`--compile=min`]],
                parallel = true,
            )
        end
    end
    @info "=== Finished xfail tests ==="
end
