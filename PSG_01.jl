#####
### PSG_01 post production of player session gap data
#####

using DataFrames, DataArrays
df = readtable("C:/Users/Peter.Mancini/Documents/Datafiles/playersessiongap.csv")

medians = [mean(df[:,:cashin]), mean(df[:,:ticketin]), mean(df[:,:bet_freq]), mean(df[:,:avg_bet])]
factors = 1 ./ (medians ./ maximum(medians))
function cossim(a,b)
  dot(a,b)/(vecnorm(a)*vecnorm(b))
end

function session_similarity(x::Int)
  if !(x>1 && x<=nrow(df))
    println(STDERR, "Index value must be > 1 and less than or equal to ", nrow(df))
    return -1.0
  end
  a = vec(Array(df[x-1,[:cashin, :ticketin, :bet_freq, :avg_bet]])) .* factors
  b = vec(Array(df[x,[:cashin, :ticketin, :bet_freq, :avg_bet]])) .* factors
  return cossim(a,b)
end

function session_similarity(x::UnitRange{Int})
  return_array = Array{Float64}(0)
  for y in x
    a = vec(Array(df[y-1,[:cashin, :ticketin, :bet_freq, :avg_bet]])) .* factors
    b = vec(Array(df[y,[:cashin, :ticketin, :bet_freq, :avg_bet]])) .* factors
    push!(return_array, cossim(a,b))
  end
  return return_array
end

function day_hour(unixtime)
  dt = Dates.unix2datetime(unixtime)
  return ([Dates.dayofweek(dt) Dates.hour(dt)])
end

gap = Array{Int32}(nrow(df))
gap[1] = 0
day = Array{Int32}(nrow(df))
day[1] = day_hour(df[1,:mss_begin])[1]
hour = Array{Int32}(nrow(df))
hour[1] = day_hour(df[1,:mss_begin])[2]

similarity = Array{Float64}(nrow(df))
similarity[1] = 1.0

last_end = df[1,:mss_end]
current_machine = df[1,:machinekey]

tic()
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
toc()

df[:gap] = gap
df[:similarity] = similarity
df[:day] = day
df[:hour] = hour

writetable("C:/Users/Peter.Mancini/Documents/Datafiles/playersessiongap_post.csv", df)
