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
    oPadding: 5,
    margin: { left: 160, bottom: 90, right: 10, top: 40 },
    style: function(e,t){return{fill:"url(#gradient)"}},
    additionalDefs: [
      <linearGradient key="gradient" x1="0" x2="1" y1="0" y2="1" id="gradient">
        <stop stopColor={theme[1]} offset="0%" />
        <stop stopColor={theme[4]} offset="100%" />
      </linearGradient>
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
    }
};

export default class ReviewsProduct extends React.Component {
  constructor(props) {
    super(props)

    this.setState({
      isLoaded: false,
      error: null
    });

    this.onButtonSort = this.onButtonSort.bind(this);

    fetch(ROOT+'eda1/reviewsproduct')
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
              How do the reviews distribute over the products? Which products usually received higher review scores?
              What about products that did not satisfy customers as much (have lowe review scores)?`}
            />
            <button onClick={this.onButtonSort}>Get TOP/Bottom</button>
            <OrdinalFrame {...this.state}
            />
          </div>
        </div>
    )}
}