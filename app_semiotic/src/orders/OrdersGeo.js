// eslint-disable-next-line no-unused-vars

import React from "react"

import { OrdinalFrame } from "semiotic"

import OrdersCity from "../orders/OrdersCity"
import OrdersState from "../orders/OrdersState"


export default class OrdersGeo extends React.Component {
  constructor(props) {
    super(props)
  }

  render() {
    return (
        <div>
          <div>
            <OrdersCity/>
            <OrdersState/>
          </div>
          <div></div>
        </div>
    )}
}
