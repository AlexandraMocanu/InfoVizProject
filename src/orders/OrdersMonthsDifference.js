import React from "react"

import { XYFrame } from "semiotic"

//const ROOT = "http://127.0.0.1:3001/"

const theme = ["#ac58e5","#E0488B","#9fd0cb","#e0d33a","#7566ff","#533f82","#7a255d","#365350","#a19a11","#3f4482"]
const frameProps = {   lines: [{ title: "2017", coordinates: [{ month: 1, orders: 955},
        { month: 2, orders: 1951 },
        { month: 3, orders: 3000 },
        { month: 4, orders: 2684 },
        { month: 5, orders: 4136 },
        { month: 6, orders: 3583 },
        { month: 7, orders: 4519 },
        { month: 8, orders: 4910 }] },
    { title: "2018", coordinates: [{ month: 1, orders: 8208 },
        { month: 2, orders: 7672 },
        { month: 3, orders: 8217 },
        { month: 4, orders: 7975 },
        { month: 5, orders: 7925 },
        { month: 6, orders: 7078 },
        { month: 7, orders: 7092 },
        { month: 8, orders: 7248 }] }],
  size: [1000,700],
  margin: { left: 80, bottom: 90, right: 10, top: 40 },
  lineType: "difference",
  xAccessor: "month",
  yAccessor: "orders",
  yExtent: [0],
  lineDataAccessor: "coordinates",
  lineStyle: (d, i) => ({
    stroke: theme[i],
    strokeWidth: 2,
    fill: theme[i],
    fillOpacity: 0.6
  }),
  title: (
    <text textAnchor="middle">
      Number of orders <tspan fill={"#ac58e5"}>2017</tspan> vs{" "}
      <tspan fill={"#E0488B"}>2018</tspan>
    </text>
  ),
  axes: [{ orient: "left", label: "Number of Orders", tickFormat: function(e){return e/1e3+"k"} },
    { orient: "bottom", label: { name: "Month", locationDistance: 55 }, ticks: 8//, tickValues: ["Jan", "Feb", "Mar", "Apr", "Jun", "Jul", "Aug"] 
  }],


    hoverAnnotation: [
        {
          type: "highlight",
          style: d => {
            return { stroke: theme[d.key], 
              strokeWidth: 5,
              fill: "none" };
          }
        },
        { type: "frame-hover" }
      ],
      showLinePoints: false,
      pointStyle: { fill: "none", r: 10 },
  
      tooltipContent: d => {
        const bothValues = [
          <div style={{ color: theme[0] }} key={"x"}>
            Month: {d.x}
          </div>,
          <div style={{ color: theme[1] }} key="y">
            Orders: {d.y}
          </div>
        ]
        const content = bothValues
        return (
          <div style={{ fontWeight: 900 }} className="tooltip-content">
            {content}
          </div>
        )
      }
}

export default () => {
  return <XYFrame {...frameProps} />
} 