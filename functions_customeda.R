library(tidyverse)
library(rjson)

Customers <- read.csv(file="../../whole_dataset/olist_customers_dataset.csv", header=TRUE, sep=",")
Geolocation <- read.csv(file="../../whole_dataset/olist_geolocation_dataset.csv", header=TRUE, sep=",")
OrderItems <- read.csv(file="../../whole_dataset/olist_order_items_dataset.csv", header=TRUE, sep=",")
OrderPayments <- read.csv(file="../../whole_dataset/olist_order_payments_dataset.csv", header=TRUE, sep=",")
OrderReviews <- read.csv(file="../../whole_dataset/olist_order_reviews_dataset.csv", header=TRUE, sep=",")
AllOrders <- read.csv(file="../../whole_dataset/olist_orders_dataset.csv", header=TRUE, sep=",")
Sellers <- read.csv(file="../../whole_dataset/olist_sellers_dataset.csv", header=TRUE, sep=",")

Products <- read.csv(file="../../whole_dataset/olist_Products_dataset.csv", header=TRUE, sep=",")
ProductsTranslation <- read.csv(file="../../whole_dataset/product_category_name_translation.csv", header=TRUE, sep=",")
colnames(ProductsTranslation)[colnames(ProductsTranslation)=="?..product_category_name"] <- "product_category_name"

ProductsTrans <- merge(x = Products, y = ProductsTranslation, by = "product_category_name")

DATABASE <- "database/database.sqlite"
data_sql <- src_sqlite(DATABASE, create = TRUE)

copy_to(data_sql, Customers)
copy_to(data_sql, Geolocation)
copy_to(data_sql, OrderItems)
copy_to(data_sql, OrderPayments)
copy_to(data_sql, OrderReviews)
copy_to(data_sql, AllOrders)
copy_to(data_sql, Sellers)
copy_to(data_sql, ProductsTrans)

library(plumber)

#* @filter cors
cors <- function(res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  plumber::forward()
}


# 1. SellersProducts
# - what do the top 20 sellers by review score who have more than 100 orders sell
## ----------- ##
#* @get /custom_sellersproducts
#* @serializer unboxedJSON
custom_sellersproducts <- function() {
  query <- paste("
  with top as (
    select s.seller_id, avg(review_score) as avg_review
    from Sellers s
    join OrderItems oi on oi.seller_id=s.seller_id
    join OrderReviews orr on orr.order_id=oi.order_id
    group by 1
    having count(distinct oi.order_id)>100
    order by 2 desc
    limit 20
  )
  SELECT p.product_category_name_english, 
    count(distinct oi.order_id) as total_orders,
    avg(op.payment_value) as avg_payment,
    count(distinct review_id) as total_reviews,
    avg(review_score) as avg_review
  FROM top
  JOIN OrderItems oi on top.seller_id=oi.seller_id
  join ProductsTrans p on p.product_id=oi.product_id
  join OrderReviews orr on orr.order_id=oi.order_id
  join OrderPayments op on orr.order_id=op.order_id
  where p.product_category_name_english<>''
  group by 1
  order by 2 desc",
                 sep = "" )
  
  result = as.data.frame(tbl(data_sql, sql(query)))
  cols = colnames(result)[!(colnames(result) %in% c("product_category_name_english","seller_city", "customer_city", "product1", "product2"))]
  
  for (c in cols){
    result[paste("scaled",c, sep="_")] = scales::rescale(result[[c]], to=c(0,1))
  }
  cols = colnames(result)[!(colnames(result) %in% c("product_category_name_english","seller_city", "customer_city", "product1", "product2"))]
  
  result <- result %>% 
    tidyr::pivot_longer(
      cols = cols, 
      names_to = "attribute", 
      values_to = "value")
  
  x <- toJSON(unname(split(result, 1:nrow(result))))
  return(list('response' = result))
}


# 2.1. % of sellers who sell y come from x
# 2.2. nb sellers + orders for ProductsTrans which have more than 100 orders
#      - ProductsTrans x,y,x are sold from these c cities (have this nb of orders) and those coming from c2 cities have highest review scores
# 2.3. ProductsTrans sold per city
## ----------- ##
#* @get /custom_sellers
#* @serializer unboxedJSON
custom_sellers <- function() {
query <- paste("
  with total as (
    SELECT p.product_category_name_english, count(distinct s.seller_id) as t_sellers, count(distinct oi.order_id) as t_orders
    FROM ProductsTrans p
    join OrderItems oi on oi.product_id=p.product_id
    join Sellers s on s.seller_id=oi.seller_id
    where p.product_category_name_english<>''
    group by 1
    having count(distinct oi.order_id)>100
  )
  SELECT p.product_category_name_english, s.seller_city, 
    t_sellers, t_orders, 
    count(distinct s.seller_id) as sellers_city, 
    count(distinct oi.order_id) as orders_city, 
    avg(review_score) as avg_review
  FROM ProductsTrans p
  join OrderItems oi on oi.product_id=p.product_id
  join OrderReviews orr on orr.order_id=oi.order_id
  join Sellers s on s.seller_id=oi.seller_id
  join total t on t.product_category_name_english=p.product_category_name_english
  where p.product_category_name_english<>''
  group by 1,2,3,4
  having count(distinct oi.order_id)>100
  order by 6 desc",
               sep = "" )

  result = as.data.frame(tbl(data_sql, sql(query)))
  colnames = colnames(result)[!(colnames(result) %in% c("product_category_name_english","seller_city"))]
  for (c in colnames){
    result[paste("scaled",c, sep="_")] = scales::rescale(result[[c]], to=c(0,1))
  }
  cols = colnames(result)[!(colnames(result) %in% c("product_category_name_english","seller_city", "customer_city", "product1", "product2"))]
  
  result <- result %>% 
    tidyr::pivot_longer(
      cols = cols, 
      names_to = "attribute", 
      values_to = "value")
  
  x <- toJSON(unname(split(result, 1:nrow(result))))
  return(list('response' = result))
}


# 3. % of customers who buy y come from x
## ----------- ##
#* @get /custom_customers
#* @serializer unboxedJSON
custom_customers <- function() {
query <- paste("
  with total as (
    SELECT p.product_category_name_english, count(distinct c.customer_unique_id) as t_customers, count(distinct oi.order_id) as t_orders
    FROM ProductsTrans p
    join OrderItems oi on oi.product_id=p.product_id
    join AllOrders ao on ao.order_id=oi.order_id
    join Customers c on c.customer_id=ao.customer_id
    where p.product_category_name_english<>''
    group by 1
    having count(distinct oi.order_id)>100
    order by 2 desc
  )
  SELECT p.product_category_name_english, c.customer_city, 
    t_customers, t_orders, 
    count(distinct c.customer_unique_id) as customers_city, 
    count(distinct oi.order_id) as orders_city, 
    avg(review_score) as avg_review
  FROM ProductsTrans p
  join total t on t.product_category_name_english=p.product_category_name_english
  join OrderItems oi on oi.product_id=p.product_id
  join OrderReviews orr on orr.order_id=oi.order_id
  join AllOrders ao on ao.order_id=oi.order_id
  join Customers c on c.customer_id=ao.customer_id
  where p.product_category_name_english<>''
  group by 1,2,3,4
  having count(distinct oi.order_id)>100
  order by 6 desc",
               sep = "" )

  result = as.data.frame(tbl(data_sql, sql(query)))
  cols = colnames(result)[!(colnames(result) %in% c("product_category_name_english","seller_city", "customer_city", "product1", "product2"))]
  
  for (c in cols){
    result[paste("scaled",c, sep="_")] = scales::rescale(result[[c]], to=c(0,1))
  }
  cols = colnames(result)[!(colnames(result) %in% c("product_category_name_english","seller_city", "customer_city", "product1", "product2"))]
  
  result <- result %>% 
    tidyr::pivot_longer(
      cols = cols, 
      names_to = "attribute", 
      values_to = "value")
  
  x <- toJSON(unname(split(result, 1:nrow(result))))
  return(list('response' = result))
}


# 4. most expensive ProductsTrans (top20) are bought by people living in these cities
## ----------- ##
#* @get /custom_mostexpensive
#* @serializer unboxedJSON
custom_mostexpensive <- function() {
query <- paste("
  with total as (
    SELECT p.product_category_name_english, avg(price) as price
    FROM ProductsTrans p
    join OrderItems oi on oi.product_id=p.product_id
    where p.product_category_name_english<>''
    group by 1
    order by 2 desc
    limit 20
  )
  SELECT p.product_category_name_english, t.price, c.customer_city, 
    count(distinct c.customer_unique_id) as customers_city, 
    count(distinct oi.order_id) as orders_city, 
    avg(review_score) as avg_review
  FROM ProductsTrans p
  join total t on t.product_category_name_english=p.product_category_name_english
  join OrderItems oi on oi.product_id=p.product_id
  join OrderReviews orr on orr.order_id=oi.order_id
  join AllOrders ao on ao.order_id=oi.order_id
  join Customers c on c.customer_id=ao.customer_id
  where p.product_category_name_english<>''
  group by 1,2,3
  order by 6 desc",
               sep = "" )
  
  result = as.data.frame(tbl(data_sql, sql(query)))
  cols = colnames(result)[!(colnames(result) %in% c("product_category_name_english", "customer_city"))]
  
  for (c in cols){
    result[paste("scaled",c, sep="_")] = scales::rescale(result[[c]], to=c(0,1))
  }
  cols = colnames(result)[!(colnames(result) %in% c("product_category_name_english", "customer_city"))]
  
  result <- result %>% 
    tidyr::pivot_longer(
      cols = cols, 
      names_to = "attribute", 
      values_to = "value")
  
  x <- toJSON(unname(split(result, 1:nrow(result))))
  return(list('response' = result))
}


# 5. orders which contained this also contained :this:
## ----------- ##
#* @get /custom_ordercontents
#* @serializer unboxedJSON
custom_ordercontents <- function() {
query <- paste("
 SELECT
      CASE WHEN t.product_category_name_english < t2.product_category_name_english THEN t.product_category_name_english ELSE t2.product_category_name_english END AS product1,
      CASE WHEN t.product_category_name_english < t2.product_category_name_english THEN t2.product_category_name_english ELSE t.product_category_name_english END AS product2,
    count(distinct oi.order_id) as orders, 
    avg(oi.price) as avg_price
  FROM ProductsTrans t
  cross join ProductsTrans t2
  join OrderItems oi on oi.product_id=t.product_id
  join OrderItems oi2 on oi.order_id=oi2.order_id and oi2.product_id=t2.product_id
  where t.product_category_name_english<>'' and t.product_category_name_english<>t2.product_category_name_english
  group by 1,2
  order by 3 desc",
               sep = "" )

  result = as.data.frame(tbl(data_sql, sql(query)))
  cols = colnames(result)[!(colnames(result) %in% c("product1", "product2"))]
  
  for (c in cols){
    result[paste("scaled",c, sep="_")] = scales::rescale(result[[c]], to=c(0,1))
  }
  cols = colnames(result)[!(colnames(result) %in% c("product1", "product2"))]
  
  result <- result %>% 
    tidyr::pivot_longer(
      cols = cols, 
      names_to = "attribute", 
      values_to = "value")
  
  x <- toJSON(unname(split(result, 1:nrow(result))))
  return(list('response' = result))
}


# 6. Orders product by time
## ----------- ##
#* @get /custom_productstime
#* @serializer unboxedJSON
custom_productstime <- function() {
query <- paste("
 SELECT
    t.product_category_name_english,
    case when strftime('%m', order_purchase_timestamp)='01' then 'January'
    when strftime('%m', order_purchase_timestamp)='02' then 'February'
    when strftime('%m', order_purchase_timestamp)='03' then 'March'
    when strftime('%m', order_purchase_timestamp)='04' then 'April'
     when strftime('%m', order_purchase_timestamp)='05' then 'May'
     when strftime('%m', order_purchase_timestamp)='06' then 'June'
     when strftime('%m', order_purchase_timestamp)='07' then 'July'
     when strftime('%m', order_purchase_timestamp)='08' then 'August'
     when strftime('%m', order_purchase_timestamp)='09' then 'September'
     when strftime('%m', order_purchase_timestamp)='10' then 'October'
     when strftime('%m', order_purchase_timestamp)='11' then 'November'
     when strftime('%m', order_purchase_timestamp)='12' then 'December'
    end purchase_month,
    count(distinct oi.order_id) as orders, 
    avg(oi.price) as avg_price
  FROM ProductsTrans t
  join OrderItems oi on oi.product_id=t.product_id
  join AllOrders ao on oi.order_id=ao.order_id
  where t.product_category_name_english<>''
  group by 1,2
  order by 3 desc",
               sep = "" )

  result = as.data.frame(tbl(data_sql, sql(query)))
  cols = colnames(result)[!(colnames(result) %in% c("product_category_name_english","purchase_month"))]
  
  for (c in cols){
    result[paste("scaled",c, sep="_")] = scales::rescale(result[[c]], to=c(0,1))
  }
  cols = colnames(result)[!(colnames(result) %in% c("product_category_name_english","purchase_month"))]
  
  result <- result %>% 
    tidyr::pivot_longer(
      cols = cols, 
      names_to = "attribute", 
      values_to = "value")
  
  x <- toJSON(unname(split(result, 1:nrow(result))))
  return(list('response' = result))
}


# 7. Delivery times by time
## ----------- ##
#* @get /custom_delivery_time
#* @serializer unboxedJSON
custom_delivery_time <- function() {
query <- paste("
 SELECT
    strftime('%m-%d', order_purchase_timestamp) as purchase_day,
    cast(julianday(order_delivered_customer_date) - julianday(order_purchase_timestamp) as Integer) as deliverytime,
    count(distinct oi.order_id) as orders, 
    avg(oi.price) as avg_price
  FROM ProductsTrans t
  join OrderItems oi on oi.product_id=t.product_id
  join AllOrders ao on oi.order_id=ao.order_id
  where t.product_category_name_english<>'' and deliverytime is not null
  group by 1,2
  order by 2 asc",
               sep = "" )

  result = as.data.frame(tbl(data_sql, sql(query)))
  cols = colnames(result)[!(colnames(result) %in% c("purchase_day","deliverytime"))]
  for (c in cols){
    result[paste("scaled",c, sep="_")] = scales::rescale(result[[c]], to=c(0,1))
  }
  cols = colnames(result)[!(colnames(result) %in% c("purchase_day","deliverytime"))]
  
  result <- result %>% 
    tidyr::pivot_longer(
      cols = cols, 
      names_to = "attribute", 
      values_to = "value")
  
  x <- toJSON(unname(split(result, 1:nrow(result))))
  return(list('response' = result))
}
