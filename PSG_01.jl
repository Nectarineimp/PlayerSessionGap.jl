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
writetable("C:/Users/Peter.Mancini/Documents/Datafiles/playersessiongap_post.csv", df)
