import React from "react"

import { XYFrame } from "semiotic"
import MarkdownText from "../MarkdownText"
import theme from "../theme"

import { scaleTime } from "d3-scale"

const ROOT = "http://127.0.0.1:3001/"

const frameProps = {  
    lines: [],
    xAccessor: ["x"],
    yAccessor: "y",
    yExtent: [0],

    // xScaleType: scaleOrdinal(),
    // xAccessor: d => d.toString(),
    
    // tickValues: [1,2,3,4,5,6,7,8,9,10,11,12],
    // xScaleType: scaleTime(),

    size: [1000,400],
    margin: { left: 80, bottom: 90, right: 10, top: 40 },

    lineStyle: (d, i) => ({
      stroke: theme[i],
      strokeWidth: 2,
      fill: "none"
    }),
    title: (
      <text textAnchor="middle">
        Number of orders per <tspan fill={"#ac58e5"}>month</tspan>
      </text>
    ),
    axes: [{ orient: "left", label: "Number of orders", tickFormat: function(e) {return e/1e3+"k"} },
      { orient: "bottom", label: { name: "Month", locationDistance: 55}
      // tickFormat: function(d) {
      //   let monthNames = ["January", "February", "March", "April", "May", "June",
      //   "July", "August", "September", "October", "November", "December"
      //   ]

      //   if (monthNames.includes(d))
      //     return monthNames[d].slice(0, 3);
      // }
    }
      ]
      

    // hoverAnnotation: [
    //   {
    //     type: "highlight",
    //     style: d => {
    //       return { stroke: theme[0], 
    //         strokeWidth: 5,
    //         fill: "none" };
    //     }
    //   },
    //   { type: "frame-hover" }
    // ],
    // showLinePoints: true,
    // pointStyle: { fill: "none", r: 10 },

    // tooltipContent: d => {
    //   const bothValues = [
    //     <div style={{ color: theme[0] }} key={"x"}>
    //       Month: {d.x}
    //     </div>,
    //     <div style={{ color: theme[1] }} key="y">
    //       Orders: {d.y}
    //     </div>
    //   ]
    //   const content = bothValues
    //   return (
    //     <div style={{ fontWeight: 900 }} className="tooltip-content">
    //       {content}
    //     </div>
    //   )
    // }
};

export default class OrdersMonth extends React.Component {
  constructor(props) {
    super(props)

    this.state = {
      isLoaded: false,
      error: null
    };

    fetch(ROOT+'ordersmonth')
      .then(response => response.json())
      .then(
        (res) => {
          this.setState({
              ...frameProps,
              lines: res.response,
              isLoaded: true,
              error: null
          });
        },
        (error) => {
        this.setState({
            ...frameProps,
            isLoaded: true,
            error
        });
      });
  }

  render() {
    return (
        <div>
          <div>
            <MarkdownText
              text={`
              Orders by month`}
            />
            <XYFrame {...this.state}
            />
          </div>
        </div>
    )};
}
