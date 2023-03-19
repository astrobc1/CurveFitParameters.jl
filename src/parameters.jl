import DataStructures: OrderedDict

export Parameter, Parameters, num_varied, is_varied, to_vecs, set_values!

"""
Type for a model parameter.

# Fields:
- `name::String`: The name of the parameter.
- `value::Float64`: The current value of the parameter.
- `lower_bound::Float64`: The lower bound.
- `upper_bound::Float64`: The upper bound.
- `vary::Bool`: Whether or not to vary the parameter during optimization.

# Constructor:
    Parameter(;name=nothing, value::Real, lower_bound::Real=-Inf, upper_bound::Real=Inf, vary::Bool=true)
Construct a new parameter. The parameter name does not have to be provided and will be automatically set if using the dictionary interface.
"""
mutable struct Parameter
    name::String
    value::Float64
    lower_bound::Float64
    upper_bound::Float64
    vary::Bool
end

function Parameter(;name::String="", value::Real, lower_bound::Real=-Inf, upper_bound::Real=Inf, vary::Bool=true)
    if lower_bound == upper_bound
        vary = false
    end
    return Parameter(name, value, lower_bound, upper_bound, vary)
end


"""
Type for a set of model parameters - wraps an `OrderedDict{String, Parameter}`. Implements the `AbstractDict` interface. Single `Parameter`'s can be accessed via `params.name` or `params["name"]`.
    
# Constructor:
    Parameters()
Constructs an empty set of parameters.

    Parameters(x::AbstractVector{<:Real}, names::AbstractVector{<:AbstractString}, lower_bounds=nothing, upper_bounds=nothing, vary=nothing)
Construct a set of parameters from `Vector`'s.
"""
struct Parameters
    dict::OrderedDict{String, Parameter}
end

function Parameters()
    return Parameters(OrderedDict{String, Parameter}())
end

"""
    Parameters(x::AbstractVector{<:Real}, names::AbstractVector{<:AbstractString}, lower_bounds=nothing, upper_bounds=nothing, vary=nothing)
Constructor from vectors.
"""
function Parameters(x::AbstractVector{<:Real}, names::AbstractVector{<:AbstractString}, lower_bounds=nothing, upper_bounds=nothing, vary=nothing)
    pars = Parameters()
    nx = length(x)
    for (i, name) ∈ enumerate(names)
        if isnothing(vary)
            _vary = true
        end
        if isnothing(lower_bounds)
            lb = -Inf
        end
        if isnothing(upper_bounds)
            ub = Inf
        end
        pars[name] = Parameter(name=name, value=x[i], lower_bound=lb, upper_bound=ub, vary=_vary)
    end
    return pars
end

Base.length(pars::Parameters) = length(pars.dict)
Base.merge!(pars::Parameters, pars2::Parameters) = merge!(pars.dict, pars2.dict)
Base.firstindex(pars::Parameters) = firstindex(pars.dict)
Base.getindex(pars::Parameters, key::String) = getindex(pars.dict, key)
Base.lastindex(pars::Parameters) = lastindex(pars.dict)
Base.iterate(pars::Parameters) = iterate(pars.dict)
Base.keys(pars::Parameters) = keys(pars.dict)
Base.values(pars::Parameters) = values(pars.dict)

function Base.getproperty(pars::Parameters, s::Symbol)
    if s == :dict
        return getfield(pars, s)
    end
    return pars[string(s)]
end

function Base.setproperty!(pars::Parameters, s::Symbol, v)
    if s == :dict
        return setfield!(pars, s, v)
    end
    pars[string(s)] = v
end

Base.setindex!(pars::Parameters, par::Parameter, key::String) = setindex!(pars.dict, par, key)

function Base.show(io::IO, par::Parameter)
    if par.vary
        println(io, " $(par.name) | Value = $(par.value) | Bounds = [$(par.lower_bound), $(par.upper_bound)]")
    else
        println(io, " $(par.name) | Value = $(par.value) 🔒 | Bounds = [$(par.lower_bound), $(par.upper_bound)]")
    end
end

function Base.show(io::IO, pars::Parameters)
    for par ∈ values(pars)
        show(io, par)
    end
end

"""
    num_varied(pars::Parameters)
Returns number of varied parameters.
"""
function num_varied(pars::Parameters)
    n = 0
    for par ∈ values(pars)
        if is_varied(par)
            n += 1
        end
    end
    return n
end

"""
    is_varied(par::Parameter)
Returns `true` if the `Parameter`'s vary field is `true` and if `lower_bound != upper_bound`.
"""
function is_varied(par::Parameter)
    return (par.lower_bound != par.upper_bound) && par.vary
end

"""
    to_vecs(pars::Parameters)
Unpacks the parameter fields to `Vector`'s. Returns a `NamedTuple` with fields `names, values, lower_bounds, upper_bounds, vary`.
"""
function to_vecs(pars::Parameters)
    names = String[par.name for par ∈ values(pars)]
    _values = Float64[par.value for par ∈ values(pars)]
    lower_bounds = Float64[par.lower_bound for par ∈ values(pars)]
    upper_bounds = Float64[par.upper_bound for par ∈ values(pars)]
    vary = BitVector([is_varied(par) for par ∈ values(pars)])
    out = (;names=names, values=_values, lower_bounds=lower_bounds, upper_bounds=upper_bounds, vary=vary)
    return out
end

"""
    set_values!(pars::Parameters, x::AbstractVector{<:Real})
    set_values!(pars::Parameters, x::Real)
Sets the values of each parameter to the value in `x`.
"""
function set_values!(pars::Parameters, x::AbstractVector{<:Real})
    for (i, par) ∈ enumerate(values(pars))
        par.value = float(x[i])
    end
end

function set_values!(pars::Parameters, x::Real)
    for (i, par) ∈ enumerate(values(pars))
        par.value = float(x)
    end
end