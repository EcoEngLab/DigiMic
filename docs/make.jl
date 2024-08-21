push!(LOAD_PATH,"../src/")

# using MiCRM
using Documenter
using DigiMic
using DigiMic.Parameters
using DigiMic.Analysis

DocMeta.setdocmeta!(DigiMic, :DocTestSetup, :(using DigiMic); recursive=true)

makedocs(;
    modules=[DigiMic],
    authors="Tom <t.clegg17@imperial.ac.uk> and contributors",
    repo="https://github.com/EcoEngLab/DigiMic/blob/{commit}{path}#{line}",
    sitename="DigiMic",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://github.com/EcoEngLab/DigiMic",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md"
        "Manual" => ["Basic Usage" => "pages/overview.md",
                    "Parameters" => ["Overview" => "pages/parameters/parameters.md",
                                    "Parameter generators" => "pages/parameters/community_generation.md",
                                    "Coalescence"=>"pages/parameters/coalescence.md"],
                    "Simulations" => ["Overview" => "pages/simulations/simulations.md",
                                    "Custom Dynamics" => "pages/simulations/custom_dynamics.md"],
                    "Analysis" => ["Overview" => "pages/analysis/analysis.md",
                                    "Effective Lottka Volterra" => "pages/analysis/GLV.md",
                                    "Local Stability Analysis" => "pages/analysis/local_stability.md"]
    ]],
)

deploydocs(;
    repo="git@github.com:EcoEngLab/DigiMic.git"
)
