@testset "Stressor growth" begin
    parameters = (
        N=1,
        M=2,
        u=[2.0 3.0],
        m=[0.5],
        l=[0.1 0.2; 0.3 0.1],
        kw=(S_ind=4, γ=[0.25]),
    )
    state = [4.0, 5.0, 6.0, 0.0]
    base_derivative = zeros(4)
    stressor_derivative = zeros(4)

    MiCRM.Simulations.growth_MiCRM!(base_derivative, state, parameters, 0.0, 1)
    MiCRM.Stressors.growth_MiCRM_stressor!(stressor_derivative, state, parameters, 0.0, 1)
    @test stressor_derivative[1] ≈ base_derivative[1]

    state[parameters.kw.S_ind] = 2.0
    fill!(stressor_derivative, 0.0)
    MiCRM.Stressors.growth_MiCRM_stressor!(stressor_derivative, state, parameters, 0.0, 1)
    @test stressor_derivative[1] ≈ base_derivative[1] - 2.0
end

@testset "Resource stress sensitivity" begin
    parameters = (
        M=2,
        u=Matrix{Float64}(I, 2, 2),
        l=zeros(2, 2),
        kw=(γ=[0.2, 0.4],),
    )

    @test MiCRM.Stressors.dRdS(parameters, [1, 2]) ≈ [0.2, 0.4]
end

@testset "System stress sensitivity" begin
    parameters = (
        N=1,
        M=1,
        u=reshape([1.0], 1, 1),
        m=[1.0],
        ρ=[1.0],
        ω=[1.0],
        l=zeros(1, 1),
        kw=(S_ind=3, γ=[0.2], d=0.0),
    )
    rhs! = (du, u, p, t) -> MiCRM.Simulations.dx!(
        du,
        u,
        p,
        t;
        growth! = MiCRM.Stressors.growth_MiCRM_stressor!,
        extrinsic! = MiCRM.Stressors.stressor!,
    )
    problem = ODEProblem(rhs!, [0.5, 1.0, 0.0], (0.0, 0.01), parameters)
    solution = solve(problem, Tsit5(); save_everystep=false)

    @test isdefined(MiCRM.Stressors, :calc_sensitivity)
    sensitivity = MiCRM.Stressors.calc_sensitivity(solution)
    @test length(sensitivity) == 2
    @test all(isfinite, sensitivity)
end

@testset "Remove extinct consumers" begin
    parameters = (
        N=2,
        M=1,
        u=reshape([1.0, 2.0], 2, 1),
        m=[0.1, 0.2],
        kw=(S_ind=4, γ=[0.3, 0.4]),
    )
    zero_rhs! = (du, u, p, t) -> fill!(du, 0.0)
    problem = ODEProblem(zero_rhs!, [0.5, 0.0, 1.0, 0.0], (0.0, 0.01), parameters)
    solution = solve(problem, Tsit5(); save_everystep=false)

    reduced = MiCRM.Stressors.remove_extinct(solution)
    @test hasproperty(reduced, :u0)
    @test reduced.u0 == [0.5, 1.0, 0.0]
    @test reduced.p.N == 1
    @test reduced.p.u == reshape([1.0], 1, 1)
    @test reduced.p.m == [0.1]
    @test reduced.p.kw.γ == [0.3]
    @test reduced.p.kw.S_ind == 3
    @test reduced.tspan == (0.0, 1.0e6)
end