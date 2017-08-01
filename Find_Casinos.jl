using DataFrames
df = readtable("C:/Users/Peter.Mancini/Downloads/server_machinecount.csv")

using Gadfly
l1 = layer(df, x="machines", Geom.histogram(bincount=24))

plot(l1)

mode(df[:machines])

#=
is this a remark?
=#
df_midsized = df[150 .<= df[:machines] .<= 300,:] # <-- that syntax is cool btw
