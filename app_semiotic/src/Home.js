import React from "react"
import MarkdownPage from "./MarkdownPage"
import SubPage from "./SubPage"

  

export default function Home() {
  return (
    <div>
      <MarkdownPage filename="home" />
      <a className="heading-link" href="#orders">
        <h2 id="orders">Orders</h2>
        </a>
        <SubPage page='Orders' />

      <a className="heading-link" href="#reviews">
        <h2 id="reviews">Reviews</h2>
        </a>
      <SubPage page='Reviews' />

      <a className="heading-link" href="#sellers">
        <h2 id="sellers">Sellers</h2>
        </a>
      <SubPage page='Sellers' />

      <a className="heading-link" href="#customers">
        <h2 id="customers">Customers</h2>
        </a>
      <SubPage page='Customers' />

      <a className="heading-link" href="#products">
        <h2 id="products">Products</h2>
        </a>
      <SubPage page='Products' />
    </div>
  )
}
