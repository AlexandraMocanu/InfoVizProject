// eslint-disable-next-line no-unused-vars

import React from "react"

import { OrdinalFrame } from "semiotic"
import MarkdownText from "../MarkdownText"
import theme from "../theme"
const ROOT = 'http://127.0.0.1:3001/'

const x_txt = {
  "(10,30]": "Between 10$ and 30$ dollars (inclusion)",
  "(30,50]": "Between 30$ and 50$ dollars (inclusion)",
  "(50,70]": "Between 50$ and 70$ dollars (inclusion)",
  "(70,100]": "Between 70$ and 100$ dollars (inclusion)",
  "(100,200]": "Between 100$ and 200$ dollars (inclusion)",
}

const frameProps = {  
    data: [],
    size: [700,700],
    type: "bar",
    projection: "horizontal",
    oAccessor: "x",
    rAccessor: "y",
    oLabel: true,

    axes: [{ orient: "left", label: {name: "Price interval", locationDistance: 70 }, tickValues: [""]}],

    margin: { left: 200, bottom: 90, right: 10, top: 40 },
    
    style: function(e,t){return{fill:"url(#triangle)"}},
    additionalDefs: [
      <pattern
        key="triangle"
        id="triangle"
        width="8"
        height="8"
        patternUnits="userSpaceOnUse"
      >
        <rect fill={theme[6]} width="10" height="10" />
        <circle fill={theme[6]} r="20" cx="10" cy="10" />
      </pattern>
    ],
    renderMode: "painty",

    pieceHoverAnnotation: [
      {
        type: "highlight",
        style: {
          stroke: "white",
          fill: "none",
          strokeWidth: 4,
          strokeOpacity: 0.5
        }
      },
      { type: "frame-hover" }
    ],
    tooltipContent: d => {
      const bothValues = [
        <div style={{ color: theme[9] }} key={"x"}>
          Price: {x_txt[d.x]}
        </div>,
        <div style={{ color: theme[12] }} key="y">
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

export default class OrdersPrice extends React.Component {
  constructor(props) {
    super(props)

    this.setState({
      isLoaded: false,
      error: null
    });

    fetch(ROOT+'eda1/ordersprice')
      .then(response => response.json())
      .then(
        (res) => {
          this.setState({
              ...frameProps,
              alldata: res.response,
              data: res.response.slice(0, 20),
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
              What are the prices of the products purchased by the customers? Do they usually buy more expensive or more cheap products?`}
            />
            <OrdinalFrame {...this.state}
            />
          </div>
        </div>
    )}
}