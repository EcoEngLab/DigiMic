using MiCRM
using LinearAlgebra
using Random
using Test

include("parameters.jl")
include("simulations.jl")
include("analysis.jl")
include("stressors.jl")

@testset "Local stability" begin
	stable_jacobian = [-2.0 0.0; 0.0 -1.0]
	unstable_jacobian = [-2.0 0.0; 0.0 0.5]
	stable_spiral = [-0.5 -1.0; 1.0 -0.5]
	unstable_spiral = [0.5 -1.0; 1.0 0.5]

	@test MiCRM.Analysis.get_stability(stable_jacobian)
	@test !MiCRM.Analysis.get_stability(unstable_jacobian)
	@test MiCRM.Analysis.get_stability(stable_spiral)
	@test !MiCRM.Analysis.get_stability(unstable_spiral)
	@test MiCRM.Analysis.get_return_rate(stable_jacobian) ≈ -1.0
	@test MiCRM.Analysis.get_return_rate(unstable_jacobian) ≈ 0.5
	@test MiCRM.Analysis.get_return_rate(stable_spiral) ≈ -0.5
	@test MiCRM.Analysis.get_return_rate(unstable_spiral) ≈ 0.5
end