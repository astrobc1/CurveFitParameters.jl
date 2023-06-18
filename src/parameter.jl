export Parameter

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