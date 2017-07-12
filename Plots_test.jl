using Gadfly

# heatmap by hour

hmdata = by(df, [:hour], x -> mean(x[:similarity]))
hmdata2 = Array(trunc(Int64, reshape(hmdata[:x1], 6,4) * 100))

p1 = plot(z=hmdata2, x=1:6, y=1:4, Geom.contour)

p2 = plot(x=0:23, y=hmdata[:x1], Geom.point, Geom.smooth(method=:loess, smoothing=0.9))

draw(SVG("Mean likelihood of stickiness by hour.svg", 10inch, 5inch), p2)

hmdata3 = by(df, [:hour], x -> [mean(x[:similarity]) std(x[:similarity])])
Ns = by(df, [:hour], x-> size(x)[1])
ymins = hmdata3[:x1] .- (1.96 * Array(hmdata3[:x2]) ./ Array(sqrt(Ns[:x1])))
ymaxs = hmdata3[:x1] .+ (1.96 * Array(hmdata3[:x2]) ./ Array(sqrt(Ns[:x1])))

p3 = plot(x=0:23, y=hmdata[:x1], ymin=ymins, ymax = ymaxs, Geom.point, Geom.smooth(method=:loess, smoothing=0.9), Geom.errorbar)

draw(SVG("Mean likelihood of stickiness by hour with error.svg", 10inch, 5inch), p3)
