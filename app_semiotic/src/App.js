import React from "react"
import Sidebar from "./Sidebar"
import ScrollToTop from "./ScrollToTop"
import SubPage from "./SubPage"
import Home from "./Home"

import ReviewScores from "./reviews/ReviewScores"
import ReviewsProduct from "./reviews/ReviewsProduct"

import OrdersCity from "./orders/OrdersCity"
import OrdersState from "./orders/OrdersState"
import OrdersProduct from "./orders/OrdersProduct"
import OrdersYear from "./orders/OrdersYear"
import OrdersMonth from "./orders/OrdersMonth"
import OrdersPrice from "./orders/OrdersPrice"
import OrdersPayment from "./orders/OrdersPayment"
import OrdersDelivery from "./orders/OrdersDelivery"

// const ROOT = process.env.PUBLIC_URL

export const PAGES = [
  {
    url: "",
    name: "Home",
    className: "bold pointer black",
    component: Home
  },
  {
    url: "orders",
    name: "Orders",
    component: SubPage,
    className: "bold pointer black",
    children: [
      {
        name: "Orders per City",
        url: "orders-city",
        component: OrdersCity
      },
      {
        name: "Orders per State",
        url: "orders-state",
        component: OrdersState
      },
      {
        name: "Orders per Product",
        url: "orders-product",
        component: OrdersProduct
      },
      {
        name: "Orders per Year",
        url: "orders-year",
        component: OrdersYear
      },
      {
        name: "Orders per Month",
        url: "orders-month",
        component: OrdersMonth
      },
      {
        name: "Orders per Price",
        url: "orders-price",
        component: OrdersPrice
      },
      {
        name: "Orders per Payment",
        url: "orders-payment",
        component: OrdersPayment
      },
      {
        name: "Orders per Delivery times",
        url: "orders-delivery",
        component: OrdersDelivery
      }
    ]
  },
  {
    url: "reviews",
    name: "Reviews",
    component: SubPage,
    className: "bold pointer black",
    children: [
      {
        name: "Review scores frequency",
        url: "review-score",
        component: ReviewScores
      },
      {
        name: "Review scores per product",
        url: "reviews-product",
        component: ReviewsProduct
      }
    ]
  }
]


const FallbackPage = props => {
    window.history.replaceState(null, null, "/")
      return <Home {...props} />
}

export default function () {
  const view = window.location.pathname.split(/#|\//g).filter(d => d)

  let View,
    viewProps = {},
    page,
    subpage

  //router logic
  if (view[0]) {
    page = PAGES.find(d => d.url === view[0])
    if (page && view[1]) {
      subpage = page.children.find(d => d.url === view[1])
      if (subpage) {
        View = subpage.component
        if (subpage.props) viewProps = subpage.props
      } else {
        View = page.component
        if (page.props) viewProps = page.props
      }
    } else if (page) {
      View = page.component
      if (page.props) viewProps = page.props
    }
  } else {
    page = PAGES[0]

    View = page.component
    viewProps = page.props
  }

  return (
    <div className="App">
      <ScrollToTop location={window.location} />
      <header className="flex">
        <div className="logo">
          {/* <img src={ROOT + "/assets/img/semiotic.png"} alt="Semiotic" /> */}
        </div>
        <div className="flex space-between">
          <h1>
            {page && page.name}
            {subpage && ` > ${subpage.name}`}
          </h1>

        </div>
      </header>
      <div className="flex body">
        <div className="sidebar">
          <div>
            <Sidebar pages={PAGES} selected={view[view.length - 1]} />
          </div>
        </div>
        <div className="container">
          <h1>
            {(subpage && subpage.name) ||
              (page && page.name && page.name !== "Home" && page.name)}
          </h1>
          <div className="margin-bottom">
            {(View && <View {...viewProps} page={page && page.name} />) || (
              <FallbackPage {...viewProps} page="Home" />
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
