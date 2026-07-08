using Pkg

Pkg.activate(@__DIR__; io = devnull)

include(joinpath(@__DIR__, "settings.jl"))

println("Building model data...")
include(joinpath(@__DIR__, "Data", "data.jl"))

model_data = build_model_data(
    workbook;
    base_year = base_year,
    horizon = horizon,
)

println()
println("Running model...")
include(joinpath(@__DIR__, "Model", "run_model.jl"))

println()
println("Full model pipeline completed.")