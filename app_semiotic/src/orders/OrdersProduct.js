// eslint-disable-next-line no-unused-vars

import React from "react"

import { OrdinalFrame } from "semiotic"
import MarkdownText from "../MarkdownText"
import theme from "../theme"
const ROOT = 'http://127.0.0.1:3001/'


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
        width="10"
        height="10"
        patternUnits="userSpaceOnUse"
      >
        <rect fill={theme[1]} width="10" height="10" />
        <circle fill={theme[1]} r="25" cx="8" cy="8" />
      </pattern>
    ],
    renderMode: "painty",
    
    tooltipContent: d => {
      const bothValues = [
        <div style={{ color: theme[0] }} key={"x"}>
          Product: {d.x}
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
    },
  
    pieceHoverAnnotation: true,
      pieceIDAccessor:"x",
  
      annotations: [
  
        { pieceHoverAnnotation: [
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
        ]},
      ],
  
      responsiveWidth: true,
};

export default class OrdersProduct extends React.Component {
  constructor(props) {
    super(props)

    this.setState({
      isLoaded: false,
      error: null
    });

    this.onButtonSort = this.onButtonSort.bind(this);

    fetch(ROOT+'eda1/ordersproduct')
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

  onButtonSort() {
    const newData = this.state.alldata.sort(function(a, b) {
      return a - b;
    }).slice(0, 20);
    this.setState({
      ...frameProps,
      alldata: this.state.alldata,
      data: newData,
      isLoaded: true,
      error: null
    });
  }

  render() {
    return (
        <div>
          <div>
            <MarkdownText
              text={`
              What type of products are most often bought? What about the the ones which are not popular?`}
            />
            <button onClick={this.onButtonSort}>Get TOP/Bottom</button>
            <OrdinalFrame {...this.state}
            />
          </div>
        </div>
    )}
}