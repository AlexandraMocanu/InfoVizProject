// eslint-disable-next-line no-unused-vars
// eslint-disable-next-line no-const-assign

import React from "react"
import distinctColors from 'distinct-colors'

import { OrdinalFrame } from "semiotic"
import MarkdownText from "../MarkdownText"
import theme from "../theme"

const ROOT = 'http://127.0.0.1:3001/'

const palette = distinctColors({count:30,hueMin:143, lightMin:35, lightMax:80, chromaMin:30, chromaMax:80});
const palette_i = {};

const tooltipStyles = {
  header: {
    fontWeight: "bold",
    borderBottom: "thin solid black",
    marginBottom: "10px",
    textAlign: "center"
  },
  lineItem: { position: "relative", display: "block", textAlign: "left" },
  title: { display: "inline-block", margin: "0 5px 0 15px" },
  value: { display: "inline-block", fontWeight: "bold", margin: "0" },
  wrapper: {
    background: "rgba(255,255,255,0.8)",
    minWidth: "max-content",
    whiteSpace: "nowrap"
  }
}

const const_data = [];
// const products = {};

const frameProps = {  
    data: [],
    size: [800,800],
    margin: { left: 40, top: 50, bottom: 75, right: 120 },

    type: "point",
    connectorType: function(e){return e.product_category_name_english},
    projection: "radial",

    oAccessor: "attribute",
    rAccessor: "value",
    rExtent: [0],

    style: function(e){return{
      fill:palette_i[e.product_category_name_english],
      stroke:"white",strokeOpacity:.5}},
    connectorStyle: function(e){return{
      fill:palette_i[e.source.product_category_name_english],
      stroke:palette_i[e.source.product_category_name_english],
      strokeOpacity:.5,fillOpacity:.5}},
    axes: true,

    pieceHoverAnnotation: true,
    tooltipContent: d => {
      const bothValues = [
        <div>
          <p style= {{ "font-family":"sans-serif", "color": theme[0] }} >
            {` ${d.attribute} = `}
          <span style={{ color: theme[1] }} key="value">
            {` ${d.value}`}
          </span>
          </p>
        </div>
      ]
      const content = bothValues

      const returnArray = [
        <div key={"header_multi"} style={tooltipStyles.header}>
          {`Statistic for: `}
          <p style={{ "text-transform": "uppercase", "font-family":"helvetica", "color": palette_i[d.product_category_name_english] }}>
            {d.product_category_name_english}</p>
        </div>
      ];

      returnArray.push(content)

      return (
        <div style={tooltipStyles.wrapper} className="tooltip-content">
          {returnArray}
        </div>
      )
    },
    oLabel: true,
    
};

export default class SoldProducts extends React.Component {
  constructor(props) {
    super(props)

    this.setState({
      isLoaded: false,
      error: null
    });

    fetch(ROOT+'custom/custom_sellersproducts')
      .then(response => response.json())
      .then(
        (res) => {
          var i = 0;
          res.response.forEach(element => {
            if (!(element.product_category_name_english in palette_i)){
              palette_i[element.product_category_name_english] = palette[i];
              i = i+1;
            }
          })
          
          var alldata = res.response;

          var filtered = alldata
          .filter(e => e.attribute.includes("scaled") 
                    || e.attribute.includes("english"))
          .reduce((obj, e) => obj.concat(e), []);

          filtered.forEach((e) => const_data.push(e));
          // const_data = filtered;

          // products = filtered.reduce((obj, e) => {
          //   obj[e.product_category_name_english] = {}
          //   obj[e.product_category_name_english].attribute = e.attribute;
          //   obj[e.product_category_name_english].value = e.value;
          //   return obj;
          //   }, {});

          this.setState({
              ...frameProps,
              alldata: alldata,
              data: filtered,
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
              Given the products sold by the top 20 sellers (by number of orders) what are their statistics?
              What is their average price, the average order count, the average review?`}
            />
            <OrdinalFrame {...this.state}
            />
          </div>
        </div>
    )}
}