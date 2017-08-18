#####
### PSG_01 post production of player session gap data
### This produces the data for gap analysis between microsession. The goal is to
### produce more accurate player sessions by throttling the break points that
### player sessionization uses.
#####

using DataFrames, DataArrays

###
# this is the primary data frame - see the sql document in this repository
# for details on how it was made.
###

# df = readtable("C:/Users/Peter.Mancini/Documents/Datafiles/Gap_Analysis.csv")
df = readtable("C:/Users/Peter.Mancini/Documents/Datafiles/Gap_Analysis_Durant.csv")

#####
### This is critical - this is how we smooth out the results. All of the elements
### of the vectors need to be normalized to the same scale. If one is much bigger
### than the others then it will dominate the direction of the vector. Without
### normalized elements, you would just throw the small numbers away and compare
### the large numbers. So if a vector looked like [0.1, 15000, 98], you may as
### well just compare the middle values because the others won't make a difference.
### We normalize by multiplying the the smaller values until their median meets
### the median of the largest value.
#####

medians = [mean(df[:,:cashin]), mean(df[:,:ticketin]), mean(df[:,:bet_freq]), mean(df[:,:avg_bet])]

factors = 1 ./ (medians ./ maximum(medians))

#####
### This is it. Cosine similarity! This is the intelligence. Seems pretty basic!
#####

"""
    cossim(a,b)

compute the cosine similarity between vector a, and vector b.
Returns a Float 1.0 >= cossim >= 0.0
"""
function cossim(a,b)
  dot(a,b)/(vecnorm(a)*vecnorm(b))
end

"""
    session_similarity(x::Int)
Assumes df, the data frame, is global and checks for cosine similarity between
the record at index x and the one prior to it.
"""
function session_similarity(x::Int)
  if !(x>1 && x<=nrow(df))
    println(STDERR, "Index value must be > 1 and less than or equal to ", nrow(df))
    return -1.0
  end
  a = vec(Array(df[x-1,[:cashin, :ticketin, :bet_freq, :avg_bet]])) .* factors
  b = vec(Array(df[x,[:cashin, :ticketin, :bet_freq, :avg_bet]])) .* factors
  return cossim(a,b)
end

"""
     session_similarity(x::UnitRange{Int})
Takes a range and determines session similarity for each item in the range.

# Examples
```julia-repl
julia> session_similarity(510:515)
Float64[6]
0.953…
0.583…
0.666…
0.982…
0.995…
0.998…
```
"""
function session_similarity(x::UnitRange{Int})
  return_array = Array{Float64}(0)
  for y in x
    a = vec(Array(df[y-1,[:cashin, :ticketin, :bet_freq, :avg_bet]])) .* factors
    b = vec(Array(df[y,[:cashin, :ticketin, :bet_freq, :avg_bet]])) .* factors
    push!(return_array, cossim(a,b))
  end
  return return_array
end

"""
    day_hour(unixtime)
Just returns an array of the day of the week and the hour of the day as Ints.
Day 1 is Sunday.
"""
function day_hour(unixtime)
  dt = Dates.unix2datetime(unixtime)
  return ([Dates.dayofweek(dt) Dates.hour(dt)])
end

###
# Start calculationg the gaps, days, and hours for the data frame.
# We create a bunch of holder arrays to keep the values and initialize them.
###

gap = Array{Int32}(nrow(df))
gap[1] = 0
day = Array{Int32}(nrow(df))
day[1] = day_hour(df[1,:mss_begin])[1]
hour = Array{Int32}(nrow(df))
hour[1] = day_hour(df[1,:mss_begin])[2]

###
# this is where we store the similarity values.
###

similarity = Array{Float64}(nrow(df))
similarity[1] = 1.0

###
# this is our current status. These let us know when changes are made and
# what unix time we will use to measure the gap.
###

last_end = df[1,:mss_end]
current_machine = df[1,:machinekey]

###
# This is the main loop that does the work.
###

for i in 2:nrow(df)
  if df[i, :machinekey] != current_machine
    gap[i] = 0
    similarity[i] = 1.0
    day[i] = day_hour(df[i, :mss_begin])[1]
    hour[i] = day_hour(df[i, :mss_begin])[2]
    last_end = df[i,:mss_end]
    current_machine = df[i,:machinekey]
    continue
  end
  gap[i] = df[i,:mss_begin] - last_end
  similarity[i] = session_similarity(i)
  day[i] = day_hour(df[i, :mss_begin])[1]
  hour[i] = day_hour(df[i, :mss_begin])[2]
  if !(gap[i] >= 0)
    println(STDERR, "Error at row ", i, " gap is zero or negative.")
    exit(-1)
  end
  last_end = df[i,:mss_end]
end

###
# Update the data frame with the values we generated. They will then be columns
# we can access like any other column in the dataframe.
###

df[:gap] = gap
df[:similarity] = similarity
df[:day] = day
df[:hour] = hour

###
# this is where we save the results. If we run into a problem or want to do
# a new analysis, you can just reload this file into a df without having
# to re-run this entire program again.
###

writetable("C:/Users/Peter.Mancini/Documents/Datafiles/playersessiongap_post.csv", df)

###
# The next file you should run is DataFrameBinning.jl to get the code you need
# for the real analysis.
###
