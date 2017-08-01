#####
### gapanalysis_stay_change.jl
# this file produces graphs and the final cubic data needed for the
# player session cutoff threshold.
####
#####
### test similarity to see if there are major differences between days. This
### should not vary much.
#####
df = readcsv("C:/Users/Peter.Mancini/Documents/Datafiles/playersessiongap_post.csv")
for i in 1:7
  println("on day ", i, " similarity is ", quantile(df[df[:day] .== i, :similarity], [0.05, 0.10, 0.15, 0.20, 0.80, 0.90, 0.95]))
end

#####
### bin the similarity data into 1% sized bins
### create other metrics that will be used. Assumption, 25%/75% is a good
### starting point for
#####
include( "./DataFrameBinning.jl" )
df[:idx] = find_bins(df[:similarity], range(0.0,0.01,101))
change_mid = sum(counts(sample(df[df[:similarity] .< 0.20,:idx], 10000), 0:20))/2
change_cumsum = cumsum(counts(sample(df[df[:similarity] .< 0.20,:idx], 10000), 0:20))
stay_mid = sum(counts(sample(df[df[:similarity] .> 0.989,:idx], 10000), 92:102))/2
stay_cumsum = cumsum(counts(sample(df[df[:similarity] .> 0.989,:idx], 10000), 92:102))

#####
### TODO: automate this so that a good set of values for the stay and chage
### thresholds can be determined with little human interferenece
#####

for i in 1:length(stay_cumsum) if stay_cumsum[i] >= stay_mid return i end end
for i in 1:length(change_cumsum) if change_cumsum[i] >= change_mid return i end end

sim_stay = 99
sim_change= 20
###
# Now let's look at the values to get a clearer understanding
###

StatsBase.summarystats(df[df[:similarity] .<= sim_change/100, :gap])
StatsBase.summarystats(df[df[:similarity] .>= sim_stay/100, :gap])
change_gap = by(df[df[:similarity] .< sim_change/100, :], :hour, x->median(x[:gap]))
Stay_gap = by(df[df[:similarity] .> sim_stay/100, :], :hour, x->median(x[:gap]))

###
# Start plotting the results
###

using Gadfly # this is basically ggplot2, very similar syntax
# hours go from 0 to 23, not 1 to 24.

l1 = layer(change_gap, x=0:23, y=:x1, Geom.point, Theme(default_color=colorant"orange"))

l2 = layer(Stay_gap,x=0:23, y=:x1, Geom.point, Theme(default_color=colorant"purple"))

# Plot 1, hour by hour gap analysis. Pretty basic.

P1 = plot(l1, l2, Guide.xlabel("Hour"),
  Guide.ylabel("seconds"),
  Guide.title("Gap Analysis"),
  Guide.manual_color_key("Legend", ["New Player", "Same Player"], ["orange", "purple"]))
draw(PNG("GapAnalysis_byhour.png", 6inch, 4inch), P1)
draw(PNG("GapAnalysis_byhour.png", 6inch, 4inch), P1)

stay_seconds = by(df[df[:similarity] .> sim_stay/100, :], :hour, x->quantile(x[:gap],[0.5]))
change_seconds = by(df[df[:similarity] .< sim_change/100, :], :hour, x->quantile(x[:gap],[0.5]))

stay_seconds_bydayhour = by(df[df[:similarity] .> sim_stay/100, :], [:day, :hour], x->quantile(x[:gap],[0.5]))
change_seconds_bydayhour = by(df[df[:similarity] .< sim_change/100, :], [:day, :hour], x->quantile(x[:gap],[0.5]))
# Plot 2, hour by hour and day by day. More sophisticated. Proves we need a
# 24x7 grid vs just an hour by hour array of thresholds.

P2 = plot(stay_seconds_bydayhour, ygroup=:day,x=:hour, y=:x1,  Geom.subplot_grid(Geom.bar), Guide.ylabel("seconds by day"))
draw(PNG("GapAnalysis_bydayhour.png", 6inch, 8inch), P2)
draw(PNG("GapAnalysis_bydayhour.png", 6inch, 8inch), P2)

#####
### The final analysis, we need similarity and gaps, hour by hour and day by day
### We also need data for our error bars. That data will be really useful in
### building our 24x7 grid of values.
### I chose 90%+ similarity for the players who stayed on the machine,
### and 25%- similarity for the change over in players. This produced a useful
### distinction between the two groups.

stay_gapmean = by(df[df[:similarity] .> sim_stay/100,:], [:day, :hour], x -> [quantile(x[:gap],[0.5]) std(x[:gap])])
Ns = by(df[df[:similarity] .> sim_stay/100,:], [:day, :hour], x-> size(x)[1])
stay_ymaxes = Array{Float64}(7,24)
stay_ymaxes2 = Array{Float64}(7,24)
stay_ymins = Array{Float64}(7,24)
for d in 1:7, h in 1:24
  i = (stay_gapmean[:day] .== d) .&  (stay_gapmean[:hour] .== (h-1))
  stay_ymaxes[d,h] = stay_gapmean[i,:x1][1] + (1.96 * stay_gapmean[i,:x2][1]) / sqrt(Ns[i,:x1][1])
  stay_ymaxes2[d,h] = stay_gapmean[i,:x1][1] + 1.5*(1.96 * stay_gapmean[i,:x2][1]) / sqrt(Ns[i,:x1][1])
  if stay_ymaxes2[d,h] > 300 stay_ymaxes2[d,h] = 300 end
  stay_ymins[d,h] = stay_gapmean[i,:x1][1] - (1.96 * stay_gapmean[i,:x2][1]) / sqrt(Ns[i,:x1][1])
end

change_gapmean = by(df[df[:similarity] .< sim_change/100,:], [:day, :hour], x -> [quantile(x[:gap],[0.5]) std(x[:gap])])
Ns = by(df[df[:similarity] .< sim_change/100,:], [:day, :hour], x-> size(x)[1])
change_ymaxes = Array{Float64}(7,24)
change_ymins = Array{Float64}(7,24)
for d in 1:7, h in 1:24
  i = (change_gapmean[:day] .== d) .&  (change_gapmean[:hour] .== (h-1))
  change_ymaxes[d,h] = change_gapmean[i,:x1][1] + (1.96 * change_gapmean[i,:x2][1]) / sqrt(Ns[i,:x1][1])
  change_ymins[d,h] = change_gapmean[i,:x1][1] - (1.96 * change_gapmean[i,:x2][1]) / sqrt(Ns[i,:x1][1])
end

### Plotting

stay_layer = layer(stay_gapmean[change_gapmean[:day] .== 6, :],
  x=0:23, y=:x1, ymin=stay_ymins[6,:], ymax=stay_ymaxes[6,:],
  Geom.point, Geom.errorbar,
  Theme(default_color=colorant"orange"))
change_layer = layer(change_gapmean[change_gapmean[:day] .== 6, :],
  x=0:23, y=:x1, ymin=change_ymins[6,:], ymax=change_ymaxes[6,:],
  Geom.point, Geom.errorbar,
  Theme(default_color=colorant"purple"))
smooth_layer = layer(x=0:23, y=stay_ymaxes2[6,:], Geom.smooth(method=:loess, smoothing=0.9))
P3 = plot(stay_layer, change_layer, smooth_layer, Theme(background_color=colorant"old lace"),
  Guide.title("Player Session Gap Analysis"),
  Guide.XLabel("Hour of Day"),
  Guide.YLabel("Typical Gap Time (Seconds)"),
  Guide.manual_color_key("Legend", ["Same Player", "New Player"], ["orange", "purple"]))

draw(PNG("GapAnalysis_bydayhour_final.png", 6inch, 8inch), P3)
draw(PNG("GapAnalysis_bydayhour_final.png", 6inch, 8inch), P3)

#####
### Achievement Unlocked! <bing!>
#####
