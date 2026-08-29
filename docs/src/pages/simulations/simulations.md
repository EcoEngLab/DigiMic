# Simulations

The state vector stores all ``N`` consumers first, followed by all ``M``
resources. `MiCRM.Simulations.dx!` implements the in-place derivative expected
by SciML `ODEProblem` solvers. On every call, it resets each consumer derivative
before the corresponding growth callback and each resource derivative before
the corresponding supply and depletion callbacks.

```@docs
MiCRM.Simulations.dx!
MiCRM.Simulations.growth_MiCRM!
MiCRM.Simulations.supply_MiCRM!
MiCRM.Simulations.depletion_MiCRM!
```
