using Documenter, IRTest

makedocs(;
    modules=[IRTest],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/tkf/IRTest.jl/blob/{commit}{path}#L{line}",
    sitename="IRTest.jl",
    authors="Takafumi Arakaki <aka.tkf@gmail.com>",
)

deploydocs(;
    repo="github.com/tkf/IRTest.jl",
)
