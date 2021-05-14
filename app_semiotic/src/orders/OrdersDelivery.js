// eslint-disable-next-line no-unused-vars

import React from "react"

import { OrdinalFrame } from "semiotic"
import MarkdownText from "../MarkdownText"
import theme from "../theme"
const ROOT = 'http://127.0.0.1:3001/'

const x_txt = {
  "(1,5]": "Between 1 and 5 days (inclusion)",
  "(5,10]": "Between 5 and 10 days (inclusion)",
  "(10,20]": "Between 10 and 20 days (inclusion)",
  "(20,30]": "Between 20 and 30 days (inclusion)",
  "(30,40]": "Between 30 and 40 days (inclusion)",
  "(40,50]": "Between 40 and 50 days (inclusion)",
  "(50,60]": "Between 50 and 60 days (inclusion)",
  "(60,70]": "Between 60 and 70 days (inclusion)",
  "(70,80]": "Between 70 and 80 days (inclusion)",
  "(80,90]": "Between 80 and 90 days (inclusion)",
  "(90,100]": "Between 90 and 100 days (inclusion)"
}

const frameProps = {  
    data: [],
    size: [700,700],
    type: "bar",
    projection: "horizontal",
    oAccessor: ["x"],
    rAccessor: "y",
    oLabel: true,
    margin: { left: 160, bottom: 90, right: 10, top: 40 },
    
    style: function(e,t){return{fill:"url(#triangle)"}},
    additionalDefs: [
      <pattern
        key="triangle"
        id="triangle"
        width="8"
        height="8"
        patternUnits="userSpaceOnUse"
      >
        <rect fill={theme[4]} width="10" height="10" />
        <circle fill={theme[4]} r="20" cx="10" cy="10" />
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
        <div style={{ color: theme[0] }} key={"x"}>
          Delivery time: {x_txt[d.x]}
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

export default class OrdersDelivery extends React.Component {
  constructor(props) {
    super(props)

    this.setState({
      isLoaded: false,
      error: null
    });

    fetch(ROOT+'eda1/ordersdelivery')
      .then(response => response.json())
      .then(
        (res) => {
          this.setState({
              ...frameProps,
              data: res.response,
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
              In how many days does an order usually arrive? (how much time it took for delivery calculated as the difference between
                the date of the order confirmation and the date of arrival at customer as per the shipping company tracking).`}
            />
            <OrdinalFrame {...this.state}
            />
          </div>
        </div>
    )}
}
