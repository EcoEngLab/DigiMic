# Basic Usage

## Introduction

This page will guide you through simulating microbial consumer resource models (MiCRMs) including community parameter generation. In general simulation of microbial communities in `MiCRM.jl` are done in three steps:

1. Generate community parameters
2. Define system dynamics
3. Simulate system

We will walk through the simulation of the basic MiCRM model given by the set of equations:

```math
\begin{aligned}
    \frac{dC_i}{dt} &= \sum_{\alpha = 0}^{M} C_i R_{\alpha} u_{i\alpha}  (1 - \lambda_{\alpha}) - C_i m_i \\
    \frac{dR_\alpha}{dt} &= \rho_{\alpha} - R_{\alpha} \omega_{\alpha} - \sum_{i = 0}^{N} C_i R_{\alpha} u_{i\alpha} + \sum_{i = 0}^{N} \sum_{\beta = 0}^{M} C_i R_{\beta} u_{i \beta} l_{\beta \alpha}
\end{aligned}
```

with parameters:

| Parameter | Description | Key |
| --- | --- | --- |
| ``C_i`` | Biomass of consumer ``i`` | - |
| ``R_{\alpha}`` | Mass of resource ``\alpha`` | - |
| ``N`` | Number of consumer populations | `N` |
| ``M`` | Number of resources | `M` |
| ``u_{i \alpha}`` | Uptake rate of resource ``\alpha`` by consumer ``i`` | `u` |
| ``m_i`` | Loss term for consumer ``i`` | `m` |
| ``\rho_{\alpha}`` | Inflow rate for resource ``\alpha`` | `ρ` |
| ``\omega_{\alpha}`` | Outflow rate for resource ``\alpha`` | `ω` |
| ``l_{\alpha \beta}`` | Fraction of resource ``\alpha`` uptake leaked as resource ``\beta`` | `l` |
| ``\lambda_{\alpha}`` | Total leaked fraction ``\sum_{\beta} l_{\alpha,\beta}`` | `λ` |

## Generating Community Parameters

The first step of any simulation is to generate a set of parameters for a given microbial community. `MiCRM.jl` stores all parameters in `NamedTuples` which are immutable (cannot be altered once created) making them fast and (as the name would suggest) indexable by name. This makes them easy to use in the derivative function. In this example we will consider a simple unstructured community where uptake and leakage values are randomly drawn from a Dirichlet distribution and all other parameters are set to 1:

```julia
    using Distributions

    #set system size and leakage
    N,M,leakage = 10,10,0.3

    #uptake
    du = Distributions.Dirichlet(N,1.0)
    u = copy(rand(du, M)')

    #cost term
    m = ones(N)

    #inflow + outflow
    ρ,ω = ones(M),ones(M)

    #leakage
    l = copy(rand(du,M)' .* leakage)

    param = (N = N, M = M, u = u, m = m, ρ = ρ, ω = ω, l = l,
             kw = (λ = leakage,))
```

In practice it is more convenient to use `generate_params`. By default it creates communities with random uptake and leakage matrices. See [Structured community generation](parameters/community_generation.md) for the included modular generators.

```julia
    using MiCRM

    #set system size and leakage
    N,M,leakage = 10,10,0.3

    #generate community parameters
    param = MiCRM.Parameters.generate_params(N, M; λ=leakage)
```

Custom parameter generators can be supplied through the `f_m`, `f_ρ`, `f_ω`, `f_u`, and `f_l` keyword arguments.

## Defining System Dynamics

Once we have a set of parameters the next step is to define the dynamics of the community we want to simulate. `MiCRM.jl` allows users to pass custom functions to `MiCRM.Simulations.dx!`; see [Custom dynamics](simulations/custom_dynamics.md). This example uses the default dynamics.

## Simulation

Once we have the parameters and the derivative equation we are ready to simulate the system and integrate through time. `MiCRM.jl` relies heavily on the brilliant `DifferentialEquations.jl` to do the numerical integration and it is worth having a look at the docs to get an idea of what is going on under the hood in your simulations. The simulation procedure is fairly straightforward and just requires that we first create an `ODEProblem` object which defines the problem for the ODE solver and then solve it with the aptly named `solve` function. `MiCRM.jl` imports a lightweight version of the `DifferentialEquations.jl` package to use so these functions are available when we run `using MiCRM`. To define the `ODEProblem` we need to specify the initial state of the system as well as the timespan we want to simulate over:

```julia
    using OrdinaryDiffEq

    #inital state
    x0 = ones(N+M)
    #time span
    tspan = (0.0, 10.0)

    #define problem
    prob = ODEProblem(MiCRM.Simulations.dx!, x0, tspan, param)
    sol = solve(prob, Tsit5())
```

## Analysis

Once the simulation is done
