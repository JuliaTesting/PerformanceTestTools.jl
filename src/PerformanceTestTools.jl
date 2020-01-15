module PerformanceTestTools

# Use README as the docstring of the module:
@doc read(joinpath(dirname(@__DIR__), "README.md"), String) PerformanceTestTools

using Test

function run_ir_test_script(script::AbstractString, include, dir::AbstractString)
    if (
        Base.JLOptions().can_inline == 0 ||  # --inline=no
        Base.JLOptions().check_bounds == 1 ||  # --check-bounds=no
        Base.JLOptions().code_coverage != 0  # not --code-coverage=none
    )
        script = isabspath(script) ? script : joinpath(dir, script)
        code = """
        $(Base.load_path_setup_code())
        include($(repr(script)))
        """
        cmd = Base.julia_cmd()
        cmd = `$cmd --check-bounds=no --code-coverage=none --inline=yes`
        if Base.JLOptions().color == 1
            cmd = `$cmd --color=yes`
        end
        @info "Running IR test in a subprocess..." cmd script
        @test success(pipeline(`$cmd -e $code`; stdout=stdout, stderr=stderr))
        @info "Running IR test in a subprocess...DONE"
    else
        include(script)
    end
end

"""
    PerformanceTestTools.@include(script)

Include a test `script` or run it in an external process if one of the
following flags is specified for the current process:

```sh
--inline=no
--check-bounds=yes
--code-coverage=user
--code-coverage=all
```

Test `script` should contain `@test` to appropriately fail when there
is a failing test.
"""
macro include(script)
    dir = dirname(string(__source__.file))
    esc(:($run_ir_test_script($script, include, $dir)))
end

end # module
