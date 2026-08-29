#defaults
"""
default params
"""
default_m(N,M,kw) = ones(N)
default_ρ(N,M,kw) = ones(M) 
default_ω(N,M,kw) = ones(M)
default_u(N,M,kw) = copy(rand(Distributions.Dirichlet(M,1.0), N)')
default_l(N,M,kw) = copy(rand(Distributions.Dirichlet(M,1.0), M)') .* kw[:λ]

"""
    generate_params(N,M;f_m = default_m, f_ρ = default_ρ, 
        f_ω = default_ω, f_u = default_u, 
        f_l = default_l, kwargs...)

Generate a parameter set for MiCRM simulations with `N` consumers and `M`
resources. Generator functions receive `(N, M, kw)`, where `kw` contains the
extra keyword arguments. The default leakage generator requires `λ` in `kw`.

By default, uptake and leakage matrices are generated from Dirichlet
distributions. Uptake rows sum to one and leakage rows sum to `λ`.

Return a `NamedTuple` containing `N`, `M`, `u`, `m`, `ρ`, `ω`, `l`, and a `kw`
`NamedTuple` containing the additional arguments.
"""
function generate_params(N,M;f_m = default_m, f_ρ = default_ρ, f_ω = default_ω, f_u = default_u, f_l = default_l, kwargs...)
    kw = Dict{Symbol,Any}(kwargs)
    #consumers
    m = f_m(N,M,kw)
    #resources
    ρ = f_ρ(N,M,kw)
    ω = f_ω(N,M,kw)
    #uptake & leakage
    u = f_u(N,M,kw)
    l = f_l(N,M,kw)

    return (N = N, M = M, u = u, m = m, ρ = ρ, ω = ω, l = l, kw = NamedTuple(zip(keys(kwargs),values(kwargs))))
end

#uptake functions
"""
    modular_uptake(N,M; N_modules = 2, s_ratio = 10.0)

Generate a modular `N × M` uptake matrix. Every consumer row is normalised to
sum to one.
    
The number of modules determines how many groups of resources the consumers are specialised over. For example if `N_modules = 2` then the resources will be split into two groups with half the consumers specialising on one and half on the other. 

`s_ratio` controls how strongly consumers favour resources in their module.
When `s_ratio = 1`, there is no modular preference; values above one increase
within-module uptake.
"""
function modular_uptake(N,M; N_modules = 2, s_ratio = 10.0)
    @assert N_modules <= M && N_modules <= N

    #baseline
    sR = M ÷  N_modules
    dR = M - (N_modules * sR)

    sC = N ÷  N_modules
    dC = N - (N_modules * sC)

    #get module sizes and add to make to M
    diffR = fill(sR, N_modules)
    diffR[sample(1:N_modules, dR, replace = false)] .+= 1
    mR = [collect(x:y) for (x,y) = zip((cumsum(diffR) .- diffR .+ 1) , cumsum(diffR))]

    #get module sizes and add to make to M
    diffC = fill(sC, N_modules)
    diffC[sample(1:N_modules, dC, replace = false)] .+= 1
    mC = [collect(x:y) for (x,y) = zip((cumsum(diffC) .- diffC .+ 1) , cumsum(diffC))]

    #preallocate u mat
    u = rand(N,M)

    #
    for (x,y) = zip(mC,mR)
        u[x,y] .*= s_ratio
    end
    
    #return u
    [u[i,:] .= u[i,:] ./ sum(u[i,:] ) for i = 1:N]

    return(u)
end

"""
    modular_uptake(N,M,kw)

Wrapper for the modular uptake to allow it to be used in the `generate_params` function.
"""
function modular_uptake(N,M,kw)
    modular_uptake(N,M,N_modules = kw[:N_modules], s_ratio = kw[:s_ratio])
end
"""
    modular_leakage(M; N_modules = 2, s_ratio = 10.0, λ = 0.5)

Generate an `M × M` leakage matrix with directional modular structure. Every
resource row is normalised to sum to `λ`.
    
The number of modules determines how many groups of resources they are split into. For example if `N_modules = 5` then the resources will be split into five groups with the first group of resources tending to leak to the second, the second to the third and so on. 
        
`s_ratio` controls the preference for leakage within the same or next module.
When `s_ratio = 1`, there is no modular preference; values above one increase
the modular preference.
"""
function modular_leakage(M; N_modules = 2, s_ratio = 10.0, λ = 0.5)
    @assert N_modules <= M
    
    #baseline
    sR = M ÷  N_modules
    dR = M - (N_modules * sR)

    #get module sizes and add to make to M
    diffR = fill(sR, N_modules)
    diffR[sample(1:N_modules, dR, replace = false)] .+= 1
    mR = [collect(x:y) for (x,y) = zip((cumsum(diffR) .- diffR .+ 1) , cumsum(diffR))]

    l = rand(M,M)

    for (i,x) = enumerate(mR)
        for (j,y) = enumerate(mR)
            if i == j || i+1 == j
                l[x,y] .*= s_ratio
            end
        end
    end

    [l[i,:] .= λ * l[i,:] ./ sum(l[i,:] ) for i = 1:M]

    return(l)
end

"""
    modular_leakage(N,M,kw::Dict{Symbol, Any})

Wrapper for the modular leakage to allow it to be used in the `generate_params` function.
"""
function modular_leakage(N,M,kw::Dict{Symbol, Any})
    modular_leakage(M; N_modules = kw[:N_modules], s_ratio = kw[:s_ratio], λ = kw[:λ])
end
