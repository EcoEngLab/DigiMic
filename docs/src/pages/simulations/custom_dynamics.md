# Defining System Dynamics

`MiCRM.Simulations.dx!` accepts `growth!`, `supply!`, `depletion!`, and
`extrinsic!` keyword callbacks. A callback can replace one contribution without
rewriting the remaining consumer-resource dynamics.

## Basic Modifications

Consumer growth callbacks receive `(du, u, p, t, consumer_index)`. Supply
callbacks receive `(du, u, p, t, resource_index)`, and depletion callbacks also
receive the consumer index.

## Advanced Modifications

An `extrinsic!` callback receives `(du, u, p, t)` and can update additional
state variables after the consumer and resource derivatives have been computed.
