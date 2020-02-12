const EnvPair = Pair{String,Union{String,Nothing}}

struct CLISpec
    options::Cmd
    env::Vector{EnvPair}
end

function Base.show(io::IO, ::MIME"text/plain", spec::CLISpec)
    get(io, :typeinfo, Any) == CLISpec || print(io, "CLISpec: ")
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

if VERSION < v"1.1"
    function _readboth(cmd)
        pipe = Pipe()
        try
            reader = @async read(pipe)
            proc = run(pipeline(cmd, stdout = pipe, stderr = pipe, stdin = devnull))
            close(pipe)
            return proc, fetch(reader)
        finally
            close(pipe)
        end
    end
else
    function _readboth(cmd)
        io = IOBuffer()
        proc = run(pipeline(cmd, stdout = io, stderr = io, stdin = devnull))
        return proc, take!(io)
    end
end

struct IncludeResult
    script::String
    spec::CLISpec
    output::String
    success::Bool
    proc::Base.Process
end

function Base.show(io::IO, ::MIME"text/plain", result::IncludeResult)
    color = result.success ? :green : :red

    printstyled(io, "┌"; color = color)
    printstyled(io, " Test result: ", bold = true)
    if result.success
        printstyled(io, "All success"; color = color, bold = true)
    else
        printstyled(io, "At least one failure"; color = color, bold = true)
    end
    println(io)

    printstyled(io, '│'; color = color)
    printstyled(io, " Script : "; color = :blue)
    printstyled(io, result.script; bold = true)
    println(io)

    printstyled(io, '│'; color = color)
    printstyled(io, " Command: "; color = :blue)
    show(IOContext(io, :typeinfo => typeof(result.spec)), MIME"text/plain"(), result.spec)
    println(io)

    for line in eachline(IOBuffer(result.output))
        printstyled(io, '│'; color = color)
        println(io, ' ', line)
    end
    printstyled(io, "└"; color = color)
    println(io)
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
        if parallel
            proc, output = _readboth(ignorestatus(cmd))
            output = String(output)
        else
            proc = run(pipeline(
                ignorestatus(cmd);
                stdout = stdout,
                stderr = stderr,
                stdin = devnull,
            ))
            output = ""
        end
        @info "Running `$script` in a subprocess...DONE"
        return IncludeResult(script, spec, output, success(proc), proc)
    end
    try
        if hasnothing
            @info "Including `$script` in this process..."
            __include(script)
            @info "Including `$script` in this process...DONE"
        end
    finally
        if parallel
            istaskdone(results) || @info "Waiting for parallel tasks..."
            results = fetch(results)
            for r in results
                show(stdout, "text/plain", r)
            end
        end
        @test all(x -> x.success, results)
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
