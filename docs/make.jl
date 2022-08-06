using CifAPI
using Documenter

DocMeta.setdocmeta!(CifAPI, :DocTestSetup, :(using CifAPI); recursive=true)

makedocs(;
    modules=[CifAPI],
    authors="Reno <singularitti@outlook.com> and contributors",
    repo="https://github.com/MineralsCloud/CifAPI.jl/blob/{commit}{path}#{line}",
    sitename="CifAPI.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://MineralsCloud.github.io/CifAPI.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/MineralsCloud/CifAPI.jl",
    devbranch="main",
)
