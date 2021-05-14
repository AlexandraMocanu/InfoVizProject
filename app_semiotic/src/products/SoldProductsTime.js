// eslint-disable-next-line no-unused-vars
// eslint-disable-next-line no-const-assign

import React from "react"
import distinctColors from 'distinct-colors'
import ReactSelect from 'react-select'
import chroma from 'chroma-js'
import { curveCatmullRom} from 'd3'

import { OrdinalFrame } from "semiotic"
import MarkdownText from "../MarkdownText"
import theme from "../theme"

const ROOT = 'http://127.0.0.1:3001/'

const dot = (color = '#ccc') => ({
  alignItems: 'center',
  display: 'flex',

  ':before': {
    backgroundColor: color,
    borderRadius: 10,
    content: '" "',
    display: 'block',
    marginRight: 8,
    height: 10,
    width: 10,
  },
});
const customStyles = {
  control: styles => ({ ...styles, backgroundColor: 'white' }),
  option: (styles, { isDisabled, isFocused, isSelected }) => {
    const color = chroma('pink');
    return {
      ...styles,
      backgroundColor: isDisabled
        ? null
        : isSelected
        ? color
        : isFocused
        ? color.alpha(0.1).css()
        : null,
      color: isDisabled
        ? '#ccc'
        : isSelected
        ? chroma.contrast(color, 'white') > 2
          ? 'white'
          : 'black'
        : color,
      cursor: isDisabled ? 'not-allowed' : 'default',

      ':active': {
        ...styles[':active'],
        backgroundColor:
          !isDisabled && (isSelected ? color : color.alpha(0.3).css()),
      },
    };
  },
  input: styles => ({ ...styles, ...dot() }),
  placeholder: styles => ({ ...styles, ...dot() }),
  singleValue: (styles, { color }) => ({ ...styles, ...dot(color) }),
}

const palette = distinctColors({count:71, hueMin:143, lightMin:35, lightMax:80, chromaMin:30, chromaMax:80});
const palette_i = {};

const monthNames = {
  "January": 1,
  "February": 2,
  "March": 3,
  "April": 4,
  "May": 5,
  "June": 6,
  "July": 7,
  "August": 8,
  "September": 9,
  "October": 10,
  "November": 11,
  "December": 12
};

const data_to_display = [
  {value: "orders", label: "Orders"}, 
  {value: "avg_price", label: "Average Price"}, 
  // {value: "scaled_orders", label: "Orders (Scaled)"}, 
  // {value: "scaled_avg_price", label: "Average Price (Scaled)"}
]
const data_map = {
  "orders": "Orders",
  "avg_price": "Average Price",
  // "scaled_orders": "Orders (Scaled)",
  // "scaled_avg_price": "Average Price (Scaled)"
}

let displayed = "orders";

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

const frameProps = {  
    data: [],
    size: [1000,2000],
    margin: { left: 170, top: 80, bottom: 75, right: 120 },

    type: "point",
    summaryType: {type: "ridgeline",
        bins: 6,
        useBins: true,
        curve: curveCatmullRom,
        relative: false
    },
    projection: "horizontal",

    oAccessor: "product_category_name_english",
    rAccessor: "purchase_month",
    rExtent: [0],
    axes: [{ ticks: 12, 
      orient: "bottom", label: "Month" }],
    rSort: (a, b) => a - b,

    responsiveWidth: true,

    style: d => {
      return {
        r: 2,
        fill: d && palette_i[d.product_category_name_english]
      }
    },
    summaryStyle: d => ({
      fill: d && palette_i[d.product_category_name_english],
      fillOpacity: 0.2,
      stroke: d && palette_i[d.product_category_name_english],
      strokeWidth: 0.5,
    }),

    pieceHoverAnnotation: true,
    tooltipContent: d => {
      const bothValues = [
        <div style={{ "font-family":"helvetica", "color": palette_i[d.product_category_name_english] }} key={"name"}>
          {d.product_category_name_english}
        </div>,
        <div>
          <p style= {{ "font-family":"sans-serif", "color": theme[0] }} >
            {` ${d.value}`}
          </p>
        </div>
      ]
      const content = bothValues

      const returnArray = [
        <div key={"header_multi"} style={tooltipStyles.header}>
          {`${data_map[displayed]} for: `}
          <p style={{ "text-transform": "uppercase", "font-family":"helvetica", "color": palette_i[d.product_category_name_english] }}>
            {Object.keys(monthNames).find(key => monthNames[key] === d["purchase_month"])}
            </p>
        </div>
      ];

      returnArray.push(content)

      return (
        <div style={tooltipStyles.wrapper} className="tooltip-content">
          {returnArray}
        </div>
      )
    },
    
    oLabel: true
    
};

export default class SoldProducts extends React.Component {
  constructor(props) {
    super(props)

    this.setState({
      isLoaded: false,
      error: null
    });

    fetch(ROOT+'custom/custom_productstime')
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
          .filter(e => e.attribute===displayed)
          .reduce((obj, e) => obj.concat(
            {"product_category_name_english": e["product_category_name_english"],
            "purchase_month": monthNames[e["purchase_month"]],
            "value": e["value"]}
            ), []);

          filtered.forEach((e) => const_data.push(e));
          
          // const_data = filtered;

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

  changeData(selection) {
    var filtered = this.state.alldata
          .filter(e => e.attribute.includes(selection))
          .reduce((obj, e) => obj.concat(
            {"product_category_name_english": e["product_category_name_english"],
            "purchase_month": monthNames[e["purchase_month"]],
            "value": e["value"]}
            ), []);

    displayed = selection;

    this.setState({
      ...frameProps,
      alldata: this.state.alldata,
      data: filtered,
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
              The products number of orders per month of year (described as raw number of orders)
              Do some products get sold more frequently during some month or another?
              And at what price do they get sold?`}
            />
            <ReactSelect input={data_map[displayed]}
            onChange={({ value }) => this.changeData(value)}
            theme={theme => ({
                ...theme,
                borderRadius: 0,
                colors: {
                  ...theme.colors,
                  primary25: 'hotpink',
                  primary: 'hotpink',
                },
              })}
            styles={customStyles} options={data_to_display} />
            <OrdinalFrame {...this.state}
            />
          </div>
        </div>
    )}
}