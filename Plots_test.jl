using Gadfly, DataFrames, DataArrays
df = readtable("C:/Users/Peter.Mancini/Documents/Datafiles/playersessiongap_post.csv")

light_panel = Theme(
    panel_fill="white",
    default_color="darkblue",
    panel_stroke="darkblue",
    background_color="old lace")

hmdata3 = by(df, [:hour], x -> [mean(x[:similarity]) std(x[:similarity])])
Ns = by(df, [:hour], x-> size(x)[1])
ymins = hmdata3[:x1] .- (1.96 * Array(hmdata3[:x2]) ./ Array(sqrt(Ns[:x1])))
ymaxs = hmdata3[:x1] .+ (1.96 * Array(hmdata3[:x2]) ./ Array(sqrt(Ns[:x1])))

#l1 = layer(hmdata[:x1], background)
p3 = plot(x=0:23, y=hmdata3[:x1], ymin=ymins, ymax = ymaxs,
  Guide.title("Mean likelihood of stickiness by hour"), Guide.xlabel("Hour"),
  Guide.ylabel("Percent"),
  Geom.point, Geom.smooth(method=:loess, smoothing=0.9), Geom.errorbar, light_panel)


draw(SVG("Mean likelihood of stickiness by hour with error.svg", 10inch, 5inch), p3)
draw(PNG("Mean likelihood of stickiness by hour with error.png", 10inch, 5inch), p3)

hmdata4 = by(df, [:hour], x -> [mean(x[:gap]) std(x[:gap])])
Ns = by(df, [:hour], x-> size(x)[1])
ymins = hmdata4[:x1] .- (1.96 * Array(hmdata4[:x2]) ./ Array(sqrt(Ns[:x1])))
ymaxs = hmdata4[:x1] .+ (1.96 * Array(hmdata4[:x2]) ./ Array(sqrt(Ns[:x1])))
p4 = plot(x=0:23, y=hmdata4[:x1], ymin=ymins, ymax = ymaxs,
  Guide.title("Mean gap between microsessions by hour"), Guide.xlabel("Hour"),
  Guide.ylabel("Seconds"),
  Geom.point, Geom.smooth(method=:loess,smoothing=0.45), Geom.errorbar, light_panel)

draw(SVG("Mean gap between microsessions by hour with error.svg", 10inch, 5inch), p4)
draw(PNG("Mean gap between microsessions by hour with error.png", 10inch, 5inch), p4)
