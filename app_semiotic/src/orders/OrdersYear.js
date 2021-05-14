import React from "react"

import { XYFrame } from "semiotic"
import MarkdownText from "../MarkdownText"
import theme from "../theme"
const ROOT = 'http://127.0.0.1:3001/'


const frameProps = {  
    lines: [],
    xAccessor: ["x"],
    yAccessor: "y",
    yExtent: [0],

    size: [1000,400],
    margin: { left: 80, bottom: 90, right: 10, top: 40 },

    lineStyle: (d, i) => ({
      stroke: theme[i],
      strokeWidth: 2,
      fill: "none"
    }),
    title: (
      <text textAnchor="middle">
        Number of orders per <tspan fill={"#ac58e5"}>year</tspan>
      </text>
    ),
    axes: [{ orient: "left", label: "Number of orders", tickFormat: function(e) {return e/1e3+"k"} },
      { orient: "bottom", label: { name: "Year", locationDistance: 55 }, ticks: 3 }],

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
    showLinePoints: true,
    pointStyle: { fill: "none", r: 10 },

    tooltipContent: d => {
      const bothValues = [
        <div style={{ color: theme[0] }} key={"x"}>
          Year: {d.x}
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
};

export default class OrdersYear extends React.Component {
  constructor(props) {
    super(props)

    this.setState({
      isLoaded: false,
      error: null
    });

    fetch(ROOT+'eda1/ordersyear')
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
              How many orders did we had per year? Are our sales going up or down?`}
            />
            <XYFrame {...this.state}
            />
          </div>
        </div>
    )}
}
