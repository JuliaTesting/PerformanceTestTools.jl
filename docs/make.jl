using Documenter, PerformanceTestTools

makedocs(;
    modules=[PerformanceTestTools],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/tkf/PerformanceTestTools.jl/blob/{commit}{path}#L{line}",
    sitename="PerformanceTestTools.jl",
    authors="Takafumi Arakaki <aka.tkf@gmail.com>",
)

deploydocs(;
    repo="github.com/tkf/PerformanceTestTools.jl",
)
