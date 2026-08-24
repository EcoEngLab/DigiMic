@testset "Parameter generation" begin
    Random.seed!(1234)
    parameters = MiCRM.Parameters.generate_params(6, 4; λ=0.25)

    @test parameters.N == 6
    @test parameters.M == 4
    @test size(parameters.u) == (6, 4)
    @test size(parameters.m) == (6,)
    @test size(parameters.ρ) == (4,)
    @test size(parameters.ω) == (4,)
    @test size(parameters.l) == (4, 4)
    @test all(parameters.u .>= 0.0)
    @test all(parameters.l .>= 0.0)
    @test vec(sum(parameters.u; dims=2)) ≈ ones(6)
    @test vec(sum(parameters.l; dims=2)) ≈ fill(0.25, 4)
    @test parameters.kw == (λ=0.25,)

    Random.seed!(1234)
    repeated = MiCRM.Parameters.generate_params(6, 4; λ=0.25)
    @test repeated.u == parameters.u
    @test repeated.l == parameters.l

    Random.seed!(4321)
    uptake = MiCRM.Parameters.modular_uptake(7, 5; N_modules=3, s_ratio=8.0)
    leakage = MiCRM.Parameters.modular_leakage(5; N_modules=3, s_ratio=8.0, λ=0.4)
    @test size(uptake) == (7, 5)
    @test vec(sum(uptake; dims=2)) ≈ ones(7)
    @test size(leakage) == (5, 5)
    @test vec(sum(leakage; dims=2)) ≈ fill(0.4, 5)

    @test_throws AssertionError MiCRM.Parameters.modular_uptake(2, 2; N_modules=3)
    @test_throws AssertionError MiCRM.Parameters.modular_leakage(2; N_modules=3)
end