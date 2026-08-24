# MiCRM.jl

[![CI](https://github.com/DigiMicOrg/DigiMic/actions/workflows/CI.yml/badge.svg)](https://github.com/DigiMicOrg/DigiMic/actions/workflows/CI.yml)

MiCRM.jl is an early-stage Julia package for constructing and simulating
microbial consumer-resource models. It includes random and modular parameter
generation, an in-place SciML derivative, local stability metrics, and
experimental stressor utilities.

## Installation

Install the package from this repository and add a SciML ODE solver:

```julia
pkg> add https://github.com/DigiMicOrg/DigiMic
pkg> add OrdinaryDiffEq
```

## Example

```julia
using MiCRM
using OrdinaryDiffEq

parameters = MiCRM.Parameters.generate_params(6, 4; λ=0.3)
initial_state = ones(parameters.N + parameters.M)
problem = ODEProblem(
    MiCRM.Simulations.dx!,
    initial_state,
    (0.0, 10.0),
    parameters,
)
solution = solve(problem, Tsit5())
```

## Development

```bash
julia --project=. -e 'using Pkg; Pkg.instantiate(); Pkg.test()'
julia --project=docs -e 'using Pkg; Pkg.develop(path="."); Pkg.instantiate()'
julia --project=docs docs/make.jl
```

The package is not currently registered in Julia's General registry.
