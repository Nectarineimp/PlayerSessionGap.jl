#####
### seconds_analysis,jl
#####
# requires nothing, so long as PSG_01.jl was run.
# experiment with various factors
import "DataFrameBinning.jl"
df = readcsv("C:/Users/Peter.Mancini/Documents/Datafiles/playersessiongap_post.csv")

σ1 = 1
σ2 = 2
σ15 = 1.5

df[:idx] = find_bins(df[:similarity], range(0.0,0.01,101))
change_mid = sum(counts(sample(df[df[:similarity] .< 0.25,:idx], 10000), 0:25))/2
change_cumsum = cumsum(counts(sample(df[df[:similarity] .< 0.25,:idx], 10000), 0:25))
stay_mid = sum(counts(sample(df[df[:similarity] .> 0.90,:idx], 10000), 75:100))/2
stay_cumsum = cumsum(counts(sample(df[df[:similarity] .> 0.90,:idx], 10000), 75:100))
