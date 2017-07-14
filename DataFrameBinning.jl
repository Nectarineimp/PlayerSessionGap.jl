### Binning example
using DataFrames, DataArrays
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

function find_bins(dv::DataFrames.DataVector{Float64}, limits::Vector{Float64})
    vbins = zeros(Int64, length(dv))
    for i in 1:length(dv)
        vbins[i] = find_bin(dv[i], limits)
    end
    vbins
end

function find_bins(dv::DataFrames.DataVector{Float64}, limits::StepRangeLen{Float64})
    vbins = zeros(Int64, length(dv))
    for i in 1:length(dv)
        vbins[i] = find_bin(dv[i], limits)
    end
    vbins
end

function group_bins{T}(df::AbstractDataFrame, col::T, limits::Vector{Float64})
    n_bins = length(limits) + 1

    vbins = find_bins(df[col], limits)
    (idx, starts) = DataArrays.groupsort_indexer(vbins, n_bins)

    # Remove zero-length groupings
    starts = _uniqueofsorted(starts)
    ends = [starts[2:end] - 1]
    GroupedDataFrame(df, [col], idx, starts[1:end-1], ends)
end

function group_bins{T}(df::AbstractDataFrame, col::T, limits::StepRangeLen{Float64})
    n_bins = length(limits) + 1

    vbins = find_bins(df[col], limits)
    (idx, starts) = DataArrays.groupsort_indexer(vbins, n_bins)

    # Remove zero-length groupings
    starts = unique(starts)
    ends = [starts[2:end] - 1]
    GroupedDataFrame(df, [col], idx, starts[1:end-1], ends)
end

x = [0.62, 0.99, 0.52, 0.03, 0.55, 0.74, 0.49, 0.31, 0.62, 0.19]
x_df = DataFrame(X=x, Y=rand(10))

group_bins(x_df, :X, range(0.0, 0.5, 20))
