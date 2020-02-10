    PerformanceTestTools.@include_foreach(script, speclist)

Include `script` for each set of Julia CLI options and environment variables
specified by `speclist` in an undefined order.

Each item in `speclist` must be

* a vector of:
  * a `Cmd` to specify CLI option(s); e.g., ``` `--compile=min` ```.
  * a `Pair{String,String}` to specify an environment variable to be added;
    e.g., `"JULIA_NUM_THREADS" => "4"`.
  * a `Pair{String,Nothing}` to specify an environment variable to be removed;
    e.g., `"JULIA_CPU_THREADS" => nothing`.
* a dictionary, instead of vector of pairs.
* `nothing` for including `script` in the current process.

Like [`@include`](@ref), test `script` should contain, e.g., `@test`
to appropriately throw when there is a failing test.

See also [`include_foreach`](@ref).

# Examples

To test with and without multi-threading enabled:

```julia
PerformanceTestTools.@include_foreach(
    "tests_using_threads.jl",
    [nothing, ["JULIA_NUM_THREADS" => "4"]],
)
```

To test both branches of `if @generated`:

```julia
PerformanceTestTools.@include_foreach(
    "tests_using_generated_functions.jl",
    [nothing, [`--compile=min`]],
)
```

To make them more robust with respect to how the current process is executed:

```julia
PerformanceTestTools.@include_foreach(
    "tests_using_threads.jl",
    [nothing, ["JULIA_NUM_THREADS" => Threads.nthreads() > 1 ? "1" : "4"]],
)

PerformanceTestTools.@include_foreach(
    "tests_using_generated_functions.jl",
    [nothing, ["--compile=min" in Base.julia_cmd() ? `--compile=yes` : `--compile=min`]],
)
```

To run a script with different CLI spces in parallel:

```julia
PerformanceTestTools.@include_foreach(
    "test.jl",
    [nothing, [`--compile=min`], [`--check-bounds=no`]],
    parallel = true,
)
```

# Keyword Arguments
- `parallel::Bool = false`: run scripts in parallel.
