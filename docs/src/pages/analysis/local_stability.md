# Local analysis

One question that we often want to ask when considering the dynamics of ecological systems is their response to perturbation. One method to answer such questions is to use local stability analysis where one linearises the system around a fixed point and then studies the dynamics of this linear system to learn about the behaviour of the system as a whole.

MiCRM.jl includes tools for automatically calculating the Jacobian matrix that defines the linearised system and for deriving key stability metrics.

## Calculating the Jacobian

MiCRM.jl calculates the Jacobian of a system using ForwardDiff.jl. For an
autonomous ODE, `Analysis.get_jac(sol)` differentiates the system at the
terminal state. The current implementation evaluates the right-hand side with
`t = 1.0`, so it should not be used unchanged for explicitly time-dependent
callbacks.

```@docs
MiCRM.Analysis.get_jac
```

## Dynamic Measures

Once the Jacobian has been calculated, it can be used to derive several stability properties.

```@docs
MiCRM.Analysis.get_Rins
MiCRM.Analysis.get_displacement
MiCRM.Analysis.get_stability
MiCRM.Analysis.get_reactivity
MiCRM.Analysis.get_return_rate
```
