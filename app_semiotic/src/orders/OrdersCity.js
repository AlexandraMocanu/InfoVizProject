// eslint-disable-next-line no-unused-vars

import React from "react"
import { AnnotationCalloutElbow, AnnotationCallout, AnnotationBadge } from 'react-annotation'

import { OrdinalFrame } from "semiotic"
import MarkdownText from "../MarkdownText"
import theme from "../theme"

const ROOT = 'http://127.0.0.1:3001/'

const populations = {
  "sao paulo": "12M",
  "rio de janeiro": "6M",
  "brasilia": "3M",
  "salvador": "2.8M",
}

const frameProps = {  
    data: [],
    size: [1000,700],
    type: "bar",
    projection: "horizontal",
    oAccessor: ["x"],
    rAccessor: "y",
    oLabel: true,
    margin: { left: 160, bottom: 90, right: 10, top: 40 },
    // style: { fill: "#ac58e5", stroke: "white" },
    style: function(e,t){return{fill:"url(#gradient)"}},
    additionalDefs: [
      <linearGradient key="gradient" x1="0" x2="0" y1="0" y2="1" id="gradient">
        <stop stopColor={"#0091adff"} offset="0%" />
        <stop stopColor={"#0091adff"} offset="100%" />
      </linearGradient>
    ],
    renderMode: "painty",

    // title: "Most orders per city",
    
    tooltipContent: d => {
      const bothValues = [
        <div style={{ color: theme[0] }} key={"x"}>
          City: {d.x}
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
        // {
        //   type: AnnotationCalloutElbow,
        //   x: "rio de janeiro",
        //   dy: 117,
        //   dx: 85,
        //   color: "#E0488B",
        //   className: "show-bg",
        //   editMode: true,
        //   note: {"title":"Annotations :)",
        //     "label":"Longer text to show text wrapping",
        //     "lineType":"vertical",
        //     "bgPadding":{"top":15,
        //             "left":10,
        //             "right":10,
        //             "bottom":10},
        //             "padding":15,
        //     "align":"middle",
        //     "wrap":1500},
        //   connector: {"end":"dot"},
        //   height: 200
        // },
        {type: AnnotationBadge,
          x:"rio de janeiro",
          dy: 117,
          dx: 85,
          color: "#E0488B",
          subject:{"radius":15,
          "text":populations["rio de janeiro"]}
        },
        {type: AnnotationBadge,
          x:"sao paulo",
          dy: 117,
          dx: 85,
          color: "#E0488B",
          subject:{"radius":15,
          "text": populations["sao paulo"]}
        },
        {type: AnnotationBadge,
          x:"brasilia",
          dy: 117,
          dx: 85,
          color: "#E0488B",
          subject:{"radius":15,
          "text":populations["brasilia"]}
        },
        {type: AnnotationBadge,
          x:"salvador",
          dy: 117,
          dx: 85,
          color: "#E0488B",
          subject:{"radius":15,
          "text":populations["salvador"]}
        },

      { pieceHoverAnnotation: [
        {
          type: "highlight",
          style: {
            stroke: "white",
            fill: "none",
            strokeWidth: 4,
            strokeOpacity: 0.5
          },
        },
        { type: "frame-hover" }
      ]},
    ],
    responsiveWidth: true,
};

export default class OrdersCity extends React.Component {
  constructor(props) {
    super(props)

    this.setState({
      isLoaded: false,
      error: null
    });

    this.onButtonSort = this.onButtonSort.bind(this);

    fetch(ROOT+'eda1/orderscity')
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
    console.log(newData)
    if (newData.some(item => item.x === 'rio de janeiro')==true){
      frameProps.annotations = [
        // {
        //   type: AnnotationCalloutElbow,
        //   x: "rio de janeiro",
        //   dy: 117,
        //   dx: 85,
        //   color: "#E0488B",
        //   className: "show-bg",
        //   editMode: true,
        //   note: {"title":"Annotations :)",
        //     "label":"Longer text to show text wrapping",
        //     "lineType":"vertical",
        //     "bgPadding":{"top":15,
        //             "left":10,
        //             "right":10,
        //             "bottom":10},
        //             "padding":15,
        //     "align":"middle",
        //     "wrap":1500},
        //   connector: {"end":"dot"},
        //   height: 200
        // },
        {type: AnnotationBadge,
          x:"rio de janeiro",
          dy: 117,
          dx: 85,
          color: "#E0488B",
          subject:{"radius":15,
          "text":populations["rio de janeiro"]}
        },
        {type: AnnotationBadge,
          x:"sao paulo",
          dy: 117,
          dx: 85,
          color: "#E0488B",
          subject:{"radius":15,
          "text": populations["sao paulo"]}
        },
        {type: AnnotationBadge,
          x:"brasilia",
          dy: 117,
          dx: 85,
          color: "#E0488B",
          subject:{"radius":15,
          "text":populations["brasilia"]}
        },
        {type: AnnotationBadge,
          x:"salvador",
          dy: 117,
          dx: 85,
          color: "#E0488B",
          subject:{"radius":15,
          "text":populations["salvador"]}
        },

      { pieceHoverAnnotation: [
        {
          type: "highlight",
          style: {
            stroke: "white",
            fill: "none",
            strokeWidth: 4,
            strokeOpacity: 0.5
          },
        },
        { type: "frame-hover" }
      ]},
    ]
    }
    else{
      frameProps.annotations = [
        { pieceHoverAnnotation: [
          {
            type: "highlight",
            style: {
              stroke: "white",
              fill: "none",
              strokeWidth: 4,
              strokeOpacity: 0.5
            },
          },
          { type: "frame-hover" }
        ]},
      ]
    }
    this.setState({
      ...frameProps,
      alldata: this.state.alldata,
      data: newData,
      isLoaded: true,
      error: null
    });
  }

  render() {
    // if (this.state.error) {
    //   return <div>Error: {this.state.error.message}</div>;
    // } else if (!this.state.isLoaded) {
    //   return <div>Loading...</div>;
    // } else {
    return (
        <div>
          <div>
            <MarkdownText
              text={`
              Orders by city`}
            />

            <button onClick={this.onButtonSort}>Get TOP/Bottom</button>
            <OrdinalFrame {...this.state}>
              <div> assd </div>
            </OrdinalFrame>

          </div>
          
        </div>
    )}
  // }
}
