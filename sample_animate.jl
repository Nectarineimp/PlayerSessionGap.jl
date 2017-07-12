using PlotlyJS

function random_line()
    n = 400
    rw() = cumsum(randn(n))
    trace1 = scatter3d(;x=rw(),y=rw(), z=rw(), mode="lines",
                        marker=attr(color="#1f77b4", size=12, symbol="circle",
                                    line=attr(color="rgb(0,0,0)", width=0)),
                        line=attr(color="#1f77b4", width=1))
    trace2 = scatter3d(;x=rw(),y=rw(), z=rw(), mode="lines",
                        marker=attr(color="#9467bd", size=12, symbol="circle",
                                    line=attr(color="rgb(0,0,0)", width=0)),
                        line=attr(color="rgb(44, 160, 44)", width=1))
    trace3 = scatter3d(;x=rw(),y=rw(), z=rw(), mode="lines",
                        marker=attr(color="#bcbd22", size=12, symbol="circle",
                                    line=attr(color="rgb(0,0,0)", width=0)),
                        line=attr(color="#bcbd22", width=1))
    layout = Layout(autosize=false, width=500, height=500,
                    margin=attr(l=0, r=0, b=0, t=65))
    PlotlyJS.plot([trace1, trace2, trace3], layout)
end
random_line()
