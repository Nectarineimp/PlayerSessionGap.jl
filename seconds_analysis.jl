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

sim_stay = 99
sim_change= 20

Stay_gap = by(df[df[:similarity] .> sim_stay/100, :], :hour, x->median(x[:gap]))
stay_seconds_bydayhour = by(df[df[:similarity] .> sim_stay/100, :], [:day, :hour], x->quantile(x[:gap],[0.5]))

change_gap = by(df[df[:similarity] .< sim_change/100, :], :hour, x->median(x[:gap]))
change_seconds_bydayhour = by(df[df[:similarity] .< sim_change/100, :], [:day, :hour], x->quantile(x[:gap],[0.5]))

Ns_stay = by(df[df[:similarity] .> sim_stay/100,:], [:day, :hour], x-> size(x)[1])
stay_ymaxes = Array{Float64}(7,24)
stay_ymins = Array{Float64}(7,24)

P1= plot(stay_seconds_bydayhour, x="hour", y="x1", Geom.point, color="day",
  Guide.title(string("Durant c:", sim_change, " s:", sim_stay)),
  Guide.YLabel("Seconds Wait Time"),
  Guide.XLabel("By Hour"))
draw(PNG("Gap_stay_bydayhour.png", 8inch, 6inch), P1)
