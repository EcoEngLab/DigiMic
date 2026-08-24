# Local analysis

One question that we often want to ask when considering the dynamics of ecological systems is their response to perturbation. One method to answer such questions is to use local stability analysis where one linearises the system around a fixed point and then studies the dynamics of this linear system to learn about the behaviour of the system as a whole.

MiCRM.jl includes tools for automatically calculating the Jacobian matrix that defines the linearised system and for deriving key stability metrics.

## Calculating the Jacobian

MiCRM.jl calculates the Jacobian of a system using ForwardDiff.jl. This automatic-differentiation back end computes derivatives of the ODE system at the terminal state through `Analysis.get_jac(sol)`.

```@docs
MiCRM.Analysis.get_jac
```

## Dynamic Measures

Once the Jacobian has been calculated, it can be used to derive several stability properties.

```@docs
MiCRM.Analysis.get_Rins
MiCRM.Analysis.get_stability
MiCRM.Analysis.get_reactivity
MiCRM.Analysis.get_return_rate
```
