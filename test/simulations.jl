@testset "MiCRM right-hand side" begin
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
    state = [4.0, 5.0, 6.0]
    derivative = fill(NaN, length(state))

    MiCRM.Simulations.dx!(derivative, state, parameters, 0.0)

    @test derivative ≈ [69.2, -13.9, -56.0]
end