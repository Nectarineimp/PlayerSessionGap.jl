using Gadfly

samplesize = 100
coord = Coord.cartesian(xmin=0.0, xmax=1.0, ymin=0.0, ymax=1.0)
xsc = Scale.x_continuous(minvalue=0.0,maxvalue=0.0)
ysc = Scale.y_continuous(minvalue=0.0,maxvalue=1.0)
colsc = Scale.color_continuous(minvalue=-0,maxvalue=1)
Data = DataFrame(X=map(sin,map(acos, session_similarity(1:samplesize))) , Y=session_similarity(1:samplesize))
Data[:slope] = Data[:Y] ./ Data[:X] # rise over run

layerAB = layer(Data, x=repeat([0], inner=samplesize), y=repeat([0], inner=samplesize), xend=:X, yend=:Y, color=:Y, Geom.segment)

p = plot(layerAB, xsc, ysc, colsc, coord)
draw(PNG("cossim.png", 6inch, 6inch), p)
