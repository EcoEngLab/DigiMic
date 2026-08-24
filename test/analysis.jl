using MiCRM
using OrdinaryDiffEq

@testset "MiCRM Jacobian" begin
    parameters = (
        N=1,
        M=2,
        u=[2.0 3.0],
        m=[0.5],
        ρ=[1.0, 2.0],
        ω=[0.1, 0.2],
        l=[0.1 0.2; 0.3 0.1],
        kw=(;),
    )
    problem = ODEProblem(MiCRM.Simulations.dx!, [4.0, 5.0, 6.0], (0.0, 0.01), parameters)
    solution = solve(problem, Tsit5(); save_everystep=false)
    consumer, resource_1, resource_2 = solution.u[end]

    expected = [
        -0.5 + 1.4resource_1 + 1.8resource_2  1.4consumer  1.8consumer
        -1.8resource_1 + 0.9resource_2          -0.1 - 1.8consumer  0.9consumer
        0.4resource_1 - 2.7resource_2           0.4consumer  -0.2 - 2.7consumer
    ]

    @test MiCRM.Analysis.get_jac(solution) ≈ expected
end

