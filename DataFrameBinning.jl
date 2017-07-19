#####
### This is the specialized code I wrote to simplify the similarity
### data. There is otherwise too much variation to find patterns.
### We use binning to reduce values to categorical values.
### For most of the analysis we simply reduce it to whole
### percents.
#####

using DataFrames, DataArrays

"""
    find_bin(x::Float64, limits::Vector{Float64})
This is a pretty simple function. It associates a value with largest value
in the limits vector.
# Examples
```julia-repl
julia> find_bin(0.357, [0.0, 0.2, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0])
3
```
"""
function find_bin(x::Float64, limits::Vector{Float64})
    bin = length(limits) + 1
    for i in 1:length(limits)
        if x < limits[i]
            bin = i
            break
        end
    end
    bin
end

"""
    find_bin(x::Float64, limits::StepRangeLen{Float64})
This is a pretty simple function. It associates a value with largest value
in the limits range.
# Examples
```julia-repl
julia> find_bin(0.357, range(0.0,0.1,11))
3
julia> find_bin(0.357, 0.0:0.1:11))
3
```
"""
function find_bin(x::Float64, limits::StepRangeLen{Float64})
    bin = length(limits) + 1
    for i in 1:length(limits)
        if x < limits[i]
            bin = i
            break
        end
    end
    bin
end

"""
    find_bins(dv::DataFrames.DataVector{Float64}, limits::Vector{Float64})
Takes a DataVector, like a column in a DataFrame, and computes the bins based
on the given range.
"""
function find_bins(dv::DataFrames.DataVector{Float64}, limits::Vector{Float64})
    vbins = zeros(Int64, length(dv))
    for i in 1:length(dv)
        vbins[i] = find_bin(dv[i], limits)
    end
    vbins
end

"""
    find_bins(dv::DataFrames.DataVector{Float64}, limits::StepRangeLen{Float64})
Takes a DataVector, like a column in a DataFrame, and computes the bins based
on the given range.
"""
function find_bins(dv::DataFrames.DataVector{Float64}, limits::StepRangeLen{Float64})
    vbins = zeros(Int64, length(dv))
    for i in 1:length(dv)
        vbins[i] = find_bin(dv[i], limits)
    end
    vbins
end

"""
    group_bins{T}(df::AbstractDataFrame, col::T, limits::Vector{Float64})
This is currently not working. It's an attempt to do a groupby with the
bins, but its probably just better to incorportate the bins as a new
column and do the groupby on the updated data frame. My kungfu wasn't
strong enough to fix this yet.
"""
function group_bins{T}(df::AbstractDataFrame, col::T, limits::Vector{Float64})
    n_bins = length(limits) + 1

    vbins = find_bins(df[col], limits)
    (idx, starts) = DataArrays.groupsort_indexer(vbins, n_bins)

    # Remove zero-length groupings
    starts = _uniqueofsorted(starts)
    ends = [starts[2:end] - 1]
    GroupedDataFrame(df, [col], idx, starts[1:end-1], ends)
end

"""
    group_bins{T}(df::AbstractDataFrame, col::T, limits::StepRangeLen{Float64})
This is currently not working. It's an attempt to do a groupby with the
bins, but its probably just better to incorportate the bins as a new
column and do the groupby on the updated data frame. My kungfu wasn't
strong enough to fix this yet.
"""
function group_bins{T}(df::AbstractDataFrame, col::T, limits::StepRangeLen{Float64})
    n_bins = length(limits) + 1

    df[:idx] = find_bins(df[col], limits)
    return groupby(df, :idx)
    # (idx, starts) = DataArrays.groupsort_indexer(vbins, n_bins)
    #
    # # Remove NA groupings
    # starts = unique(starts)
    # ends = [starts[2:end] - 1]
    # #GroupedDataFrame(df, [col], idx, starts[1:end-1], ends)
    # groupby(df, [col], idx, starts[1:end-1], ends)
end

#####
### Here are some tests, they are useful in getting a feel for how binning
### operates.
# x_df = DataFrame(X=randn(30), Y=rand(30))
#
# find_bins(x_df[:X], Array(range(0.0, 0.5, 21)))
#####

#####
# the next file you should run is gapanalyisis_stay_change.jl
#####
