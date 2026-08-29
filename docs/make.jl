using Documenter
using MiCRM

DocMeta.setdocmeta!(MiCRM, :DocTestSetup, :(using MiCRM); recursive=true)

makedocs(;
    modules=[MiCRM],
    checkdocs=:none,
    authors="Tom <t.clegg17@imperial.ac.uk> and contributors",
    repo="https://github.com/DigiMicOrg/DigiMic/blob/{commit}{path}#{line}",
    sitename="DigiMic.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        edit_link="main",
        repolink="https://github.com/DigiMicOrg/DigiMic",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md"
        "Manual" => ["Basic Usage" => "pages/overview.md",
                    "Parameters" => ["Overview" => "pages/parameters/parameters.md",
                                    "Parameter generators" => "pages/parameters/community_generation.md"],
                    "Simulations" => ["Overview" => "pages/simulations/simulations.md",
                                    "Custom Dynamics" => "pages/simulations/custom_dynamics.md"],
                    "Analysis" => ["Overview" => "pages/analysis/analysis.md",
                                    "Local Stability Analysis" => "pages/analysis/local_stability.md"]
    ]],
)

deploydocs(;
    repo="github.com/DigiMicOrg/DigiMic.git",
    devbranch="main",
    versions=["dev" => "dev", "stable" => "v^", "v#.#"],
)
