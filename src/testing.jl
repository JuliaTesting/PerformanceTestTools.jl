"""
Internal module used for testing.
"""
module _Testing

using Test

struct XFailTestSet <: Test.AbstractTestSet
    ts::Test.AbstractTestSet

    XFailTestSet(ts::Test.AbstractTestSet) = new(ts)
end

XFailTestSet(args...; kwargs...) =
    XFailTestSet(typeof(Test.get_testset())(args...; kwargs...))

Test.finish(ts::XFailTestSet) = Test.finish(ts.ts)
Test.record(ts::XFailTestSet, result::Test.Pass) = Test.record(
    ts.ts,
    Test.Fail(
        Symbol(:xfail_, result.test_type),
        result.orig_expr,
        result.data,
        result.value,
        LineNumberNode(0, Symbol("<unknown>")),
    ),
)
Test.record(ts::XFailTestSet, result::Test.Fail) = Test.record(
    ts.ts,
    Test.Pass(
        Symbol(:xfail_, result.test_type),
        result.orig_expr,
        result.data,
        result.value,
    ),
)
Test.record(ts::XFailTestSet, result::Test.Error) = Test.record(ts.ts, result)

end  # module
