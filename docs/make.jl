pushfirst!(LOAD_PATH, "/Users/cale/Development/CurveFitParameters/src/")

using Documenter
using CurveFitParameters

makedocs(
    sitename = "CurveFitParameters",
    format = Documenter.HTML(),
    modules = [
        CurveFitParameters
    ],
    pages = [
        "index.md",
        "api.md"
    ]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo = "github.com/astrobc1/CurveFitParameters.jl.git"
)