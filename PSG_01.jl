#####
### PSG_01 post production of player session gap data
#####

using DataFrames, DataArrays
df = readtable("C:/Users/Peter.Mancini/Documents/Datafiles/playersessiongap.csv")

gap = Array{Int32}(nrow(df))
gap[1] = 0
last_end = df[1,:mss_end]
current_machine = df[1,:machinekey]

for i in 2:nrow(df)
  if df[i, :machinekey] != current_machine
    gap[i] = 0
    last_end = df[i,:mss_end]
    current_machine = df[i,:machinekey]
    continue
  end
  gap[i] = df[i,:mss_begin] - last_end
  if !(gap[i] >= 0)
    println(STDERR, "Error at row ", i, " gap is zero or negative.")
    exit(-1)
  end
  last_end = df[i,:mss_end]
end
df[:gap] = gap
function cossim(a,b)
  dot(a,b)/(vecnorm(a)*vecnorm(b))
end

function session_similarity(x::Int)
  a = Array(df[x,[:cashplayed,	:cashin, :ticketin, :bet_freq, :avg_bet]])
  b = Array(df[x+1,[:cashplayed,	:cashin, :ticketin, :bet_freq, :avg_bet]])
  return cossim(a,b)
end
function session_similarity(x::UnitRange{Int})
  return_array = Array{Float64}(0)
  for y in x
    a = Array(df[y,[:cashplayed,	:cashin, :ticketin, :bet_freq, :avg_bet]])
    b = Array(df[y+1,[:cashplayed,	:cashin, :ticketin, :bet_freq, :avg_bet]])
    push!(return_array, cossim(a,b))
  end
  return return_array
end


writetable("C:/Users/Peter.Mancini/Documents/Datafiles/playersessiongap_post.csv", df)
