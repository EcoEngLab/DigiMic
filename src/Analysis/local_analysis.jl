"""
    get_jac(sol)

For an autonomous ODE, calculate the system Jacobian at the solution's terminal
state with automatic differentiation. The caller is responsible for ensuring
that the terminal state is an equilibrium. The right-hand side is evaluated at
`t = 1.0`, so this method does not represent the terminal-time Jacobian for an
explicitly time-dependent system.
"""
function get_jac(sol::T; thresh = eps()) where T <: DiffEqBase.AbstractODESolution
    #assert equilibrium
    function f(x)
        dx = similar(x)
        dx .= 0.0
        # MiCRM.Simulations.dx!(dx,x,p,1.0)
        deriv = SciMLBase.unwrapped_f(sol.prob.f)
        deriv(dx,x,sol.prob.p,1.0)
        return(dx)
    end

    return(ForwardDiff.jacobian(f, sol.u[end]))
end

"""
    get_jac(sol::DiffEqBase.SteadyStateSolution)

Calculate the Jacobian at a steady-state solution. The right-hand side is
evaluated at `t = 1.0`; use this method unchanged only for autonomous systems.
"""
function get_jac(sol::DiffEqBase.SteadyStateSolution)
    function f(x)
        dx = similar(x)
        dx .= 0.0
        # MiCRM.Simulations.dx!(dx,x,p,1.0)
        deriv = SciMLBase.unwrapped_f(sol.prob.f)
        deriv(dx,x,sol.prob.p,1.0)
        return(dx)
    end

    return(ForwardDiff.jacobian(f, sol.u))
end

"""
    get_stability(J)

Return `true` when every eigenvalue of the Jacobian has a negative real part.
"""
function get_stability(J)
    maximum(real, eigvals(J)) < 0.0
end

"""
    get_displacement(J, u, t, w = ones(size(J)[1]))

Calculate the squared weighted displacement of a perturbation at time `t`.
"""
function get_displacement(J, u, t, w = ones(size(J)[1]))
    (w .* exp(J * t) * u)' * (w .* exp(J * t) * u)
end

"""
    get_Rins(J, u, t, w = ones(size(J)[1]))

Calculate the instantaneous rate of growth of perturbation `u` at time `t`.
The optional observation weights `w` select or weight state variables.
"""
function get_Rins(J, u, t, w = ones(size(J)[1]))
    # tr(J * exp(J * t) * u * w') / tr(exp(J * t) * u * w')
    x = exp(J * t) * u
    dx = J * exp(J * t) * u
    #norm
    x_n = (w .* x)' * (w .* x)
    dx_n = (w .* dx)' * (w .* x) + (w .* x)' * (w .* dx)

    return(dx_n / (2 * x_n))
end
    
"""
    get_reactivity(J,u)

Return `true` when perturbation `u` is initially amplified away from the
equilibrium.
"""
function get_reactivity(J,u)
    get_Rins(J, u, 0.0) > 0.0
end

"""
    get_return_rate(J)

Return the real part of the leading Jacobian eigenvalue. Negative values imply
asymptotic return toward the equilibrium.
"""
function get_return_rate(J)
    maximum(real, eigvals(J))
end
