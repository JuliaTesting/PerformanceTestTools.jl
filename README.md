# PerformanceTestTools

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://juliatesting.github.io/PerformanceTestTools.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://juliatesting.github.io/PerformanceTestTools.jl/dev)
[![Build Status](https://travis-ci.com/JuliaTesting/PerformanceTestTools.jl.svg?branch=master)](https://travis-ci.com/JuliaTesting/PerformanceTestTools.jl)
[![Codecov](https://codecov.io/gh/JuliaTesting/PerformanceTestTools.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaTesting/PerformanceTestTools.jl)
[![Coveralls](https://coveralls.io/repos/github/JuliaTesting/PerformanceTestTools.jl/badge.svg?branch=master)](https://coveralls.io/github/JuliaTesting/PerformanceTestTools.jl?branch=master)
[![GitHub commits since tagged version](https://img.shields.io/github/commits-since/JuliaTesting/PerformanceTestTools.jl/v0.1.3.svg?style=social&logo=github)](https://github.com/JuliaTesting/PerformanceTestTools.jl)

Testing generated IRs inside CI is useful for avoiding performance
regression.  However, test suites are normally run under flags like
`--check-bounds=yes` and `--code-coverage=user` which block `julia`
compiler to generate efficient code.
`PerformanceTestTools.@include(script)` automatically detects such
flags and run the `script` in a separate `julia` process started
without these flags.
