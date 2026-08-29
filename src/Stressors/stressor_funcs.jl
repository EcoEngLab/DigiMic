#dynamics
"""
    growth_MiCRM_stressor!(dx,x,p,t,i)

Growth function for the stressor model. It subtracts the additional mortality
loss `C_i * S * γ_i` from the standard MiCRM consumer dynamics.
"""
function growth_MiCRM_stressor!(dx,x,p,t,i)
    growth_MiCRM!(dx,x,p,t,i)
    dx[i] -= x[i] * x[p.kw.S_ind] * p.kw.γ[i]
end

"""
    stressor!(dx,x,p,t)

Implement `dS/dt = d * S`. The stressor decays when `d < 0`, is constant when
`d = 0`, and grows when `d > 0`.
"""
function stressor!(dx,x,p,t)
    dx[p.kw.S_ind] = p.kw.d * x[p.kw.S_ind]
end

#analysis
# Define functions to calculate sensitivity.
"""
    dRdS(p,C_extant)

Calculate resource sensitivities for a parameter set and its extant consumers.
"""
function dRdS(p,C_extant)   
    return(pinv(p.u[C_extant,:] * diagm((ones(p.M) - p.l * ones(p.M)))) * p.kw.γ[C_extant])
end

"""
    dCdS(p, C_extant, R, C, dR)

Calculate consumer sensitivity from the parameters and equilibrium state.
"""
function dCdS(p, C_extant, R, C, dR)
   leakage_factor = (p.l' - I(p.M))
       
    a = pinv(leakage_factor * diagm(R) * p.u[C_extant,:]')
    b = diagm(dR) * p.ω - leakage_factor * diagm(dR) * p.u[C_extant,:]' * C[C_extant]

    return(a * b)
end

"""
    calc_sensitivity(sol)

Calculate consumer and resource sensitivity to the stressor. The result lists
extant consumers in their original index order followed by all resources;
extinct consumers and the stressor state are omitted.
"""
function calc_sensitivity(sol)
    state = sol.u[end]
    C,R = state[1:sol.prob.p.N], state[sol.prob.p.N + 1:end - 1]
    
    C_extant = findall(C .> eps())
    
    dR = dRdS(sol.prob.p, C_extant)
    dC = dCdS(sol.prob.p, C_extant, R, C, dR)
    
    return(vcat(dC[:],dR[:]))
end

calc_sensitvtiy(sol) = calc_sensitivity(sol)

"""
    remove_extinct(sol)

Return a remade problem with consumers below machine precision removed and its
time span set to `(0.0, 1e6)`.
"""
function remove_extinct(sol)
    p = sol.prob.p
    state = sol.u[end]
    
    to_keep = findall(state[1:p.N] .> eps())
    to_rm = findall(state[1:p.N] .< eps())
    
    p_dict = Dict(zip(keys(p),values(p)))

    #remove from params
    p_dict[:u] = p_dict[:u][to_keep,:]
    p_dict[:m] = p_dict[:m][to_keep]
    p_dict[:N] = length(to_keep)

    #stressor keywords
    kw_dict = Dict(zip(keys(p_dict[:kw]), values(p_dict[:kw])))
    kw_dict[:γ] = kw_dict[:γ][to_keep]
    kw_dict[:S_ind] = p_dict[:N] + p_dict[:M] + 1

    p_dict[:kw] = NamedTuple(kw_dict)

    p_new = NamedTuple(p_dict)
    
    u0 = copy(state)
    deleteat!(u0, to_rm)

    return(DiffEqBase.remake(sol.prob; u0=u0, tspan=(0.0,1e6), p=p_new))
end
