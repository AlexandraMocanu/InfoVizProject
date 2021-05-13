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
    style: { fill: "#ac58e5", stroke: "white" },
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
      // .then(data => {
      //   this.setState({ ...frameProps, data: data.response})
      // });

      // const mapRef = useRef();
      // const [mapdata] = useState({
      //   counties: [],
      //   orders: []
      // });

      // fetch(ROOT+'orderscounties')
      // .then(response => response.json())
      // .then(res => {
      //     this.setCountiesData({
      //         data: res.response
      //     });
      //   });

      // useEffect(() => {
      //   if (data.length) {
      //     const formattedData = formatData(data[0].feed.entry)
      //     setCountiesData( prevState => ({
      //       ...prevState,
      //       allParks: formattedData,
      //       activeParks: formattedData,
      //     }));
      //   }
      // }, [data]);

      // const filterParksByPark = park => {
      //   setParkData({
      //     ...parkData,
      //     activeParks: [park],
      //     activeBorough: park.borough
      //   });
      // }

      // const filterParksByBorough = borough => {
      //     const parksByBorough = parkData.allParks.filter( park => {
      //       return borough   === 'all' ? park : park.borough === borough 
      //     });
      //     setParkData({
      //       ...parkData,
      //       activeParks: parksByBorough,
      //       activeBorough: borough
      //     });
      // };
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
              Score cities`}
            />
            <button onClick={this.onButtonSort}>Get TOP/Bottom</button>
            <OrdinalFrame {...this.state}
            />
          </div>
          {/* <div>
        <MapChart width={600} height={400} data={[60, 30, 40, 20, 30]} />
      </div> */}
        </div>
    )}
  // }
}
