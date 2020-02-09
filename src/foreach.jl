const EnvPair = Pair{String,Union{String,Nothing}}

struct CLISpec
    options::Cmd
    env::Vector{EnvPair}
end

function Base.show(io::IO, ::MIME"text/plain", spec::CLISpec)
    print(io, "CLISpec: ")
    for (k, v) in spec.env
        print(io, k, '=')
        if v === nothing
            printstyled(io, '❌'; color = :red)
        else
            show(io, v)
        end
        print(io, ' ')
    end
    printstyled(io, raw"$julia"; color = :blue)
    isempty(spec.options) || print(io, ' ')
    join(io, spec.options, ' ')
end

CLISpec(spec::AbstractDict) = CLISpec(``, collect(EnvPair, spec))

function CLISpec(spec::AbstractVector)
    env = EnvPair[]
    options = ``
    for s in spec
        if s isa Cmd
            options = `$options $s`
        else
            push!(env, s)
        end
    end
    return CLISpec(options, env)
end

function env_from_spec(spec::CLISpec)
    env = copy(ENV)
    for (k, v) in spec.env
        if v === nothing
            pop!(env, k)
        else
            env[k] = v
        end
    end
    return env
end

"""
    PerformanceTestTools.include_foreach(script, speclist)

Like [`@include_foreach`](@ref) but relative path `script` is resolved
with respect to the current working directory, instead of the file in
which this function is called.
"""
function include_foreach(script, speclist0; parallel::Bool = false, __include = _include)
    speclist = CLISpec[]
    hasnothing = false
    for x in speclist0
        if x === nothing
            hasnothing = true
        else
            push!(speclist, CLISpec(x))
        end
    end

    script = abspath(script)
    if parallel
        _map = (f, xs) -> @async asyncmap(f, xs; ntasks = Sys.CPU_THREADS)
    else
        _map = map
    end
    results = _map(speclist) do spec
        env = env_from_spec(spec)
        code = """
        $(Base.load_path_setup_code())
        include($(repr(script)))
        """
        cmd = setenv(`$(_julia_cmd()) -e $code $(spec.options)`, env)
        @info "Running `$script` in a subprocess..." spec
        ok = success(pipeline(cmd; stdout = stdout, stderr = stderr))
        @info "Running `$script` in a subprocess...DONE"
        return ok
    end
    try
        if hasnothing
            @info "Including `$script` in this process..."
            __include(script)
            @info "Including `$script` in this process...DONE"
        end
    finally
        if parallel
            results = fetch(results)
        end
        @test all(results)
    end
end

@doc read(joinpath(@__DIR__, "foreach.md"), String) :(@include_foreach)

macro include_foreach(script, args...)
    dir = dirname(string(__source__.file))
    args = map(args) do ex
        isexpr(ex, :(=)) ? Expr(:kw, ex.args...) : ex
    end
    esc(:($include_foreach($joinpath($dir, $script), __include = include, $(args...))))
end
