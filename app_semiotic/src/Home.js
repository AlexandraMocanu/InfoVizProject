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
    </div>
  )
}
