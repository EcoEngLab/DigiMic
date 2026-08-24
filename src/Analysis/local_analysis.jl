"""
    get_jac(sol)

Numerically calculate jacobian of system from the solution object. Assumes that the system is at equilibrium so the end state is used. 
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

For steady-state solution types.
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

Determine the stability a system given its jaccobian by testing if the real part of the leading eigenvalue is positive. 
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
    get_Rins(J, t, w = ones(size(J)[1]))

Caclulate the instantaneous rate of growth of the perturbation u at time t. The observation vector `w` can be optionally supplied to consider linear combinations of the state variables. This can include any linear combination of state variables such as the mass of specific components of the system as well as total functioning measures. 
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

Test wether the system is "reactive" to the perturbation `u`. A reactive is system is one where the initial perturbation is amplified so that the deviation from equilibrium initially increases 
"""
function get_reactivity(J,u)
    get_Rins(J, u, 0.0) > 0.0
end

"""
    get_return_rate(J)

get the rate of return of the system from perturbation. This value is determined by the leading eigenvalue regardless of the direction of the perturbation or the observation vector we choose. 
"""
function get_return_rate(J)
    maximum(real, eigvals(J))
end
