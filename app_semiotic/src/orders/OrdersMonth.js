import XYFrame from "semiotic/lib/XYFrame"

const theme = ["#ac58e5","#E0488B","#9fd0cb","#e0d33a","#7566ff","#533f82","#7a255d","#365350","#a19a11","#3f4482"]
const frameProps = {   lines: [{ title: "Ex Machina", coordinates: [{ month: 1, orders: 6 },
        { month: 2, orders: 363 },
        { month: 3, orders: 1 },
        { month: 4, orders: 955 },
        { month: 5, orders: 1951 },
        { month: 6, orders: 3000 },
        { month: 7, orders: 2684 },
        { month: 8, orders: 4136 },
        { month: 9, orders: 3583 },
        { month: 10, orders: 4519 },
        { month: 11, orders: 4910 },
        { month: 12, orders: 4831 },
        { month: 13, orders: 5322 },
        { month: 14, orders: 8665 },
        { month: 15, orders: 6308 },
        { month: 16, orders: 8208 },
        { month: 17, orders: 7672 },
        { month: 18, orders: 8217 },
        { month: 19, orders: 7975 },
        { month: 20, orders: 7925 },
        { month: 21, orders: 7078 },
        { month: 22, orders: 7092 },
        { month: 23, orders: 7248 },] },
     ],
  size: [1000,500],
  margin: { left: 80, bottom: 90, right: 10, top: 40 },
  xAccessor: "month",
  yAccessor: "orders",
  yExtent: [0],
  lineStyle: (d, i) => ({
    stroke: theme[i],
    strokeWidth: 2,
    fill: "none"
  }),
  title: (
    <text textAnchor="middle">
      Number of orders from <tspan fill={"#ac58e5"}>2016</tspan> until{" "}
      <tspan fill={"#E0488B"}>2018</tspan>
    </text>
  ),
  axes: [{ orient: "left", label: "Number of Orders", tickFormat: function(e){return e/1e3+"k"} },
    { orient: "bottom", label: { name: "Month", locationDistance: 55 }, tickValues: [""]}],
    
  hoverAnnotation: true,

  tooltipContent: d => {
      const bothValues = [
        <div style={{ color: theme[0] }} key={"month"}>
          Month: {d.month}
        </div>,
        <div style={{ color: theme[1] }} key="orders">
          Orders: {d.orders}
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