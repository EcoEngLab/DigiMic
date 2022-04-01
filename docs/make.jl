push!(LOAD_PATH,"../src/")

# using MiCRM
using Documenter
using MiCRM

DocMeta.setdocmeta!(MiCRM, :DocTestSetup, :(using MiCRM); recursive=true)

makedocs(;
    modules=[MiCRM],
    authors="Tom <t.clegg17@imperial.ac.uk> and contributors",
    repo="https://github.com/cleggtom/MiCRM.jl/blob/{commit}{path}#{line}",
    sitename="MiCRM.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://cleggtom.github.io/MiCRM.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Manual" => ["Guide" => "guide.md"
                     "Examples" => "examples.md"],
        "Library" => ["Public" => "public.md",
                      "Internal" => "internal.md"]
    ],
)

deploydocs(;
    repo="github.com/CleggTom/MiCRM.jl.git",
    devbranch="main",
)
