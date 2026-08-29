# Basic usage

## Introduction

DigiMic.jl provides the `MiCRM` Julia module for simulating microbial
consumer-resource models. A basic workflow has three steps:

1. Generate community parameters.
2. Define the system dynamics.
3. Integrate the system through time with a SciML solver.

The default dynamics implement

```math
\begin{aligned}
    \frac{dC_i}{dt} &= C_i \sum_{\alpha = 1}^{M} R_{\alpha} u_{i\alpha}
        (1 - \lambda_{\alpha}) - C_i m_i, \\
    \frac{dR_\alpha}{dt} &= \rho_{\alpha} - R_{\alpha} \omega_{\alpha}
        - \sum_{i = 1}^{N} C_i R_{\alpha} u_{i\alpha}
        + \sum_{i = 1}^{N} \sum_{\beta = 1}^{M}
          C_i R_{\beta} u_{i\beta} l_{\beta\alpha},
\end{aligned}
```

where ``\lambda_\alpha = \sum_{\beta=1}^{M} l_{\alpha\beta}`` is the
total fraction of resource ``\alpha`` uptake that is leaked.

| Parameter | Description | Key |
| --- | --- | --- |
| ``C_i`` | Biomass of consumer ``i`` | state entries `1:N` |
| ``R_{\alpha}`` | Mass of resource ``\alpha`` | state entries `N+1:N+M` |
| ``N`` | Number of consumer populations | `N` |
| ``M`` | Number of resources | `M` |
| ``u_{i \alpha}`` | Uptake rate of resource ``\alpha`` by consumer ``i`` | `u` |
| ``m_i`` | Loss term for consumer ``i`` | `m` |
| ``\rho_{\alpha}`` | Inflow rate for resource ``\alpha`` | `ρ` |
| ``\omega_{\alpha}`` | Outflow rate for resource ``\alpha`` | `ω` |
| ``l_{\alpha \beta}`` | Fraction of resource ``\alpha`` uptake leaked as resource ``\beta`` | `l` |
| ``\lambda_{\alpha}`` | Total leaked fraction ``\sum_{\beta} l_{\alpha\beta}`` | row sum of `l` |

## Generating community parameters

`MiCRM` stores a parameter set in a `NamedTuple`. Its fields cannot be replaced,
but array-valued fields such as `u` and `l` remain mutable. The following
example constructs an unstructured parameter set directly. It uses different
consumer and resource counts to make the matrix dimensions explicit.

```julia
N, M, leakage = 10, 8, 0.3

# Each consumer has a normalised distribution over M resources.
u = rand(N, M)
u ./= sum(u; dims=2)

m = ones(N)
ρ = ones(M)
ω = ones(M)

# Each resource leaks a total fraction into M possible resources.
l = rand(M, M)
l .*= leakage ./ sum(l; dims=2)

parameters = (
    N=N,
    M=M,
    u=u,
    m=m,
    ρ=ρ,
    ω=ω,
    l=l,
    kw=(λ=leakage,),
)
```

In most cases, use [`MiCRM.Parameters.generate_params`](@ref) instead. Its
default uptake rows sum to one and its default leakage rows sum to the required
`λ` value.

```julia
using MiCRM

N, M, leakage = 10, 8, 0.3
parameters = MiCRM.Parameters.generate_params(N, M; λ=leakage)
```

Custom generators can be supplied through the `f_m`, `f_ρ`, `f_ω`, `f_u`, and
`f_l` keyword arguments. See [Structured community generation](parameters/community_generation.md).

## Defining system dynamics

[`MiCRM.Simulations.dx!`](@ref) implements the default in-place derivative.
Its component callbacks can be replaced without rewriting the full model; see
[Custom dynamics](simulations/custom_dynamics.md).

## Simulation

`MiCRM` supplies the model derivative, while `OrdinaryDiffEq` supplies the
`ODEProblem`, solver algorithms, and `solve` function.

```julia
using MiCRM
using OrdinaryDiffEq

initial_state = ones(parameters.N + parameters.M)
timespan = (0.0, 10.0)

problem = ODEProblem(
    MiCRM.Simulations.dx!,
    initial_state,
    timespan,
    parameters,
)
solution = solve(problem, Tsit5())
```

The state vector contains all ``N`` consumers followed by all ``M`` resources.
Choose solver tolerances, output times, and termination criteria according to
the scientific question being studied.

## Analysis

For an autonomous solution whose terminal state is an equilibrium,
[`MiCRM.Analysis.get_jac`](@ref) calculates the local Jacobian. The analysis
module can then test local stability and quantify perturbation responses; see
[Local analysis](analysis/local_stability.md).
