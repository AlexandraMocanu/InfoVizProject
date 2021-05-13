// eslint-disable-next-line no-unused-vars

import React from "react"

import { OrdinalFrame } from "semiotic"
import MarkdownText from "../MarkdownText"
import theme from "../theme"
import { AnnotationCalloutElbow, AnnotationCallout, AnnotationBadge } from 'react-annotation'

const ROOT = 'http://127.0.0.1:3001/'

const gdp = {
  "SP": "583B",
  "RJ": "183B",
  "MG": "155B",
  "RS": "116B"
}

const frameProps = {  
    data: [],
    size: [1000,700],
    type: "bar",
    projection: "horizontal",
    oAccessor: ["x"],
    rAccessor: "y",
    oLabel: true,
    oPadding: 15,
    margin: { left: 160, bottom: 90, right: 10, top: 20 },
    // style: { fill: "#ac58e5", stroke: "white" },
    style: function(e,t){return{fill:"url(#triangle)"}},
  additionalDefs: [
    <pattern
      key="triangle"
      id="triangle"
      width="10"
      height="10"
      patternUnits="userSpaceOnUse"
    >
      <rect fill={theme[2]} width="10" height="10" />
      <circle fill={theme[2]} r="20" cx="10" cy="10" />
    </pattern>
  ],
  renderMode: "painty",

  tooltipContent: d => {
    const bothValues = [
      <div style={{ color: theme[0] }} key={"x"}>
        State: {d.x}
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
        {type: AnnotationBadge,
          x:"RJ",
          dy: 117,
          dx: 85,
          color: theme[3],
          subject:{"radius":17,
          "text":gdp["RJ"]}
        },
        {type: AnnotationBadge,
          x:"SP",
          dy: 117,
          dx: 85,
          color: theme[3],
          subject:{"radius":17,
          "text": gdp["SP"]}
        },
        {type: AnnotationBadge,
          x:"MG",
          dy: 117,
          dx: 85,
          color: theme[3],
          leftRight: "right",
          subject:{"radius":17,
          "text":gdp["MG"]}
        },
        {type: AnnotationBadge,
          x:"RS",
          dy: 117,
          dx: 85,
          color: theme[3],
          subject:{"radius":17,
          "text":gdp["RS"]}
        },

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

export default class OrdersState extends React.Component {
  constructor(props) {
    super(props)

    this.setState({
      isLoaded: false,
      error: null
    });

    fetch(ROOT+'eda1/ordersstate')
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
              Orders by state`}
            />
            <OrdinalFrame {...this.state}
            />
          </div>
        </div>
    )}
}