# Structured community generation

MiCRM provides generators for modular consumer uptake and directional resource
leakage. Each uptake row sums to one. Each leakage row sums to `λ`, the total
fraction of consumed resource that is leaked.

```julia
parameters = MiCRM.Parameters.generate_params(
    12,
    8;
    λ=0.3,
    N_modules=4,
    s_ratio=8.0,
    f_u=MiCRM.Parameters.modular_uptake,
    f_l=MiCRM.Parameters.modular_leakage,
)
```

```@docs
MiCRM.Parameters.modular_uptake
MiCRM.Parameters.modular_leakage
```
