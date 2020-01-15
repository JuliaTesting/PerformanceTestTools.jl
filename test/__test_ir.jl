using InteractiveUtils: code_llvm, code_warntype
using Test

"""
    llvm_ir(f, args) :: String

Get LLVM IR of `f(args...)` as a string.
"""
llvm_ir(f, args) = sprint(code_llvm, f, Base.typesof(args...))

nmatches(r, s) = count(_ -> true, eachmatch(r, s))

function vdot(xs, ys)
    d = zero(eltype(xs)) + zero(eltype(ys))
    @simd for i in eachindex(xs, ys)
        x = @inbounds xs[i]
        y = @inbounds ys[i]
        d += x * y
    end
    return d
end

@testset begin
    v = Float64[]
    @test nmatches(r"fadd fast <[0-9]+ x double>", llvm_ir(vdot, (v, v))) >= 4
end
