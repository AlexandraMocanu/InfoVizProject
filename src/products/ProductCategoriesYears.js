import OrdinalFrame from "semiotic/lib/OrdinalFrame"
import theme from "../theme"

const colorHash = {
  Year2016: "#ac58e5",
  Year2017: "#9fd0cb",
  Year2018: "#E0488B"
}

const rAccessor = ["Year2016", "Year2017", "Year2018"]

const frameProps = {   data: [{ product_category: "bed_bath_table", Year2016: 14, Year2017: 1275, Year2018: 1776 },
    { product_category: "health_beauty", Year2016: 51, Year2017: 3668, Year2018: 5951 },
    { product_category: "sports_leisure", Year2016: 19, Year2017: 4095, Year2018: 4527 },
    { product_category: "furniture_decor", Year2016: 69, Year2017: 4147, Year2018: 4118 },
    { product_category: "computers_accessories", Year2016: 21, Year2017: 3098, Year2018: 4708 }],
  size: [1000,500],
  margin: { left: 130, bottom: 90, right: 10, top: 40 },
  type: "clusterbar",
  projection: "horizontal",
  oPadding: 5,
  oAccessor: "product_category",
  rAccessor: rAccessor,
  style: d => {

          // in v1.19.6+ a d.rName is exposed so instead
          // you can call return { fill: colorHash[d.rName], stroke: "white" }
          return { fill: colorHash[rAccessor[d.rIndex]], stroke: "white" }
        },
  title: "Top 5 Product Categories Orders per Year",
  axes: [{
    orient: "bottom",
    label: (
      <text textAnchor="middle">
        <tspan fill={colorHash.Year2016}>2016</tspan> +{" "}
        <tspan fill={colorHash.Year2017}>2017</tspan> +{" "}
        <tspan fill={colorHash.Year2018}>2018</tspan>
      </text>
    )
  }],
  oLabel: true
}

export default () => {
  return <OrdinalFrame {...frameProps} />
}