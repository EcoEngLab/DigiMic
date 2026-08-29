# DigiMic.jl

[![CI](https://github.com/DigiMicOrg/DigiMic/actions/workflows/CI.yml/badge.svg)](https://github.com/DigiMicOrg/DigiMic/actions/workflows/CI.yml)
[![Documentation](https://img.shields.io/badge/docs-dev-blue.svg)](https://digimicorg.github.io/DigiMic/)

DigiMic.jl is the DigiMic platform's early-stage Julia repository for
constructing and simulating microbial consumer-resource models. It includes
random and modular parameter generation, an in-place SciML derivative, local
stability metrics, and experimental stressor utilities.

The Julia package and root module are currently named `MiCRM`; install from this
repository and import it with `using MiCRM`.

See the [package documentation](https://digimicorg.github.io/DigiMic/) for
the model equations, parameter conventions, simulation interface, and analysis
utilities. For the wider package ecosystem and training materials, visit the
[DigiMic platform](https://digimicorg.github.io/).

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
