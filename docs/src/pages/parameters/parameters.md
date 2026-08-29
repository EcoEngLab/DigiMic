# Parameters

The `MiCRM.Parameters` submodule generates parameter sets for the default
consumer-resource dynamics and for user-defined variants.

## Parameter representation

A parameter set is a `NamedTuple`. Its named fields cannot be replaced, but
array-valued fields remain mutable. The default derivative expects the
following fields:

| Key | Shape | Description |
| --- | --- | --- |
| `N` | scalar | Number of consumer populations |
| `M` | scalar | Number of resources |
| `u` | `N × M` | Consumer uptake rates |
| `m` | `N` | Consumer loss rates |
| `ρ` | `M` | Resource inflow rates |
| `ω` | `M` | Resource outflow rates |
| `l` | `M × M` | Leakage fractions from rows into columns |
| `kw` | `NamedTuple` | Additional model or callback parameters |

The state variables are not stored in this tuple. A simulation state contains
the `N` consumers first and the `M` resources second; see
[Simulations](../simulations/simulations.md).

## Generating parameter sets

The default generators draw random uptake and leakage matrices. Supply `λ`,
the total leakage fraction assigned to every resource row:

```julia
parameters = MiCRM.Parameters.generate_params(10, 8; λ=0.3)
```

```@docs
MiCRM.Parameters.generate_params
```

Custom generators are passed as `f_m`, `f_ρ`, `f_ω`, `f_u`, or `f_l`.
Each receives `(N, M, kw)`, where `kw` is a dictionary containing the extra
keywords supplied to `generate_params`. A generator must return the shape
required by the table above.

See [Structured community generation](community_generation.md) for the included
modular uptake and leakage generators.
