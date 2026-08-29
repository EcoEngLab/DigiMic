# Defining custom dynamics

[`MiCRM.Simulations.dx!`](@ref) accepts `growth!`, `supply!`,
`depletion!`, and `extrinsic!` keyword callbacks. Replacing one callback
changes that contribution without requiring a copy of the complete derivative.

## Callback contracts

- `growth!(du, u, p, t, i)` updates consumer `i`.
- `supply!(du, u, p, t, α)` updates resource `α`.
- `depletion!(du, u, p, t, i, α)` adds consumer `i`'s effect on resource
  `α`.
- `extrinsic!(du, u, p, t)` runs after the consumer and resource loops and can
  update additional state variables.

For each consumer, `dx!` resets that consumer's derivative before calling
`growth!`. For each resource, it resets that resource's derivative before
calling `supply!` and then `depletion!` for every consumer. By the time
`extrinsic!` runs, the first `N + M` entries have been assigned. An
`extrinsic!` callback is responsible for assigning the derivatives of any
additional states.

## Example: additional consumer mortality

The following growth callback first applies the default growth dynamics and
then adds a constant per-capita mortality rate:

```julia
using MiCRM
using OrdinaryDiffEq

parameters = MiCRM.Parameters.generate_params(
    6,
    4;
    λ=0.3,
    extra_mortality=0.05,
)

function mortality_growth!(du, u, p, t, i)
    MiCRM.Simulations.growth_MiCRM!(du, u, p, t, i)
    du[i] -= p.kw.extra_mortality * u[i]
end

function mortality_rhs!(du, u, p, t)
    MiCRM.Simulations.dx!(
        du,
        u,
        p,
        t;
        growth! = mortality_growth!,
    )
end

problem = ODEProblem(
    mortality_rhs!,
    ones(parameters.N + parameters.M),
    (0.0, 10.0),
    parameters,
)
solution = solve(problem, Tsit5())
```
