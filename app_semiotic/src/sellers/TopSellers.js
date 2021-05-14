// eslint-disable-next-line no-unused-vars

import React from "react"

import { OrdinalFrame } from "semiotic"
import MarkdownText from "../MarkdownText"
import theme from "../theme"

const ROOT = "http://127.0.0.1:3001/"


const frameProps = {  
    data: [],
    size: [700,700],
    type: "bar",
    projection: "horizontal",
    oAccessor: ["x"],
    rAccessor: "y",
    oLabel: true,
    margin: { left: 160, bottom: 90, right: 10, top: 40 },
    style: { fill: theme[2], stroke: "white" },
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
          City: {d.x}
        </div>,
        <div style={{ color: theme[1] }} key="y">
          Score: {d.y}
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

export default class TopSellers extends React.Component {
  constructor(props) {
    super(props)

    this.state = {
      isLoaded: false,
      error: null
    };

    this.onButtonSort = this.onButtonSort.bind(this);

    fetch(ROOT+'eda1/scorecities')
      .then(response => response.json())
      .then(
        (res) => {
          this.setState({
              ...frameProps,
              alldata: res.response,
              data: res.response.slice(0, 50),
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
    }).slice(0, 50);
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
              Based on the reviews scores given by customers, where do the sellers given higher ratings come from? (in terms of cities)
              Are sellers from certain cities more 'good' than others?
              What about the 'worst' sellers?`}
            />
            <button onClick={this.onButtonSort}>Get TOP/Bottom</button>
            <OrdinalFrame {...this.state}
            />
          </div>
        </div>
    )}
}
