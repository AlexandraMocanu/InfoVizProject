#### Plumber settings
library(plumber)


#* @filter cors
cors <- function(res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  plumber::forward()
}
getwd()
####

#### DATA PREP AND READING
require(lubridate)
Customers <- read.csv(file="./whole_dataset/olist_customers_dataset.csv", header=TRUE, sep=",")
Geolocation <- read.csv(file="./whole_dataset/olist_geolocation_dataset.csv", header=TRUE, sep=",")
OrderItems <- read.csv(file="./whole_dataset/olist_order_items_dataset.csv", header=TRUE, sep=",")
OrderPayments <- read.csv(file="./whole_dataset/olist_order_payments_dataset.csv", header=TRUE, sep=",")
OrderReviews <- read.csv(file="./whole_dataset/olist_order_reviews_dataset.csv", header=TRUE, sep=",")
AllOrders <- read.csv(file="./whole_dataset/olist_orders_dataset.csv", header=TRUE, sep=",")
Products <- read.csv(file="./whole_dataset/olist_products_dataset.csv", header=TRUE, sep=",")
Sellers <- read.csv(file="./whole_dataset/olist_sellers_dataset.csv", header=TRUE, sep=",")
ProductsTranslation <- read.csv(file="./whole_dataset/product_category_name_translation.csv", header=TRUE, sep=",")

colnames(ProductsTranslation)[1] <- "product_category_name"

# 1. Orders by city
# xlab = "City of delivery/order (top 10)", ylab = "Number of orders"
city_orders = merge(Customers, AllOrders, by="customer_id")
most_orders_city <- sort(table(city_orders$customer_city), decreasing=T)
## ----------- ##
#* @get /orderscity
#* @serializer unboxedJSON
orderscity <- function() {
  # df=as.data.frame(most_orders_city[0:20])
  df=as.data.frame(most_orders_city)
  colnames(df)<-c("x", "y")
  return(list('response' = df))
}


# 1.2. Orders by state
# xlab = "City of delivery/order (top 10)", ylab = "Number of orders"
city_orders = merge(Customers, AllOrders, by="customer_id")
most_orders_state <- sort(table(city_orders$customer_state), decreasing=T)
## ----------- ##
#* @get /ordersstate
#* @serializer unboxedJSON
ordersstate <- function() {
  df=as.data.frame(most_orders_state)
  colnames(df)<-c("x", "y")
  return(list('response' = df))
}




# 2. Orders by product type 
# xlab = "Product category (top 10)", ylab = "Number of orders"
products_orders = merge(AllOrders, OrderItems, by="order_id")
products_orders_names = merge(products_orders, Products, by="product_id")
products_orders_names_eng = merge(products_orders_names, ProductsTranslation, by="product_category_name")
most_orders_type <- sort(table(products_orders_names_eng$product_category_name_english), decreasing = T)
## ----------- ##
#* @get /ordersproduct
#* @serializer unboxedJSON
ordersproduct <- function() {
  df=as.data.frame(most_orders_type)
  colnames(df)<-c("x", "y")
  return(list('response' = df))
}

prod_years.lub = ymd_hms(products_orders_names_eng$order_purchase_timestamp)
orders_years <- year(prod_years.lub)
orders_years
products_orders_names_eng$orders_years = orders_years

Freqs <- table(products_orders_names_eng$product_category_name_english, products_orders_names_eng$orders_years)
Freqs


# 3. Orders by year
# xlab = "Product category (top 10)", ylab = "Number of orders"
years.lub = ymd_hms(products_orders$order_purchase_timestamp)
most_orders_years <- table(year(years.lub))
## ----------- ##
#* @get /ordersyear
#* @serializer unboxedJSON
ordersyear <- function() {
  df=as.data.frame(most_orders_years)
  colnames(df)<-c("x", "y")
  return(list('response' = df))
}


# 4. Orders by month
# xlab = "Order month", ylab = "Number of orders"
months.lub = ymd_hms(products_orders$order_purchase_timestamp)
months.lub
# months_pl <- factor(month(months.lub), labels = c("Jan", "Feb", "Mar", "Apr",
#                                               "May", "Jun", "Jul", "Aug",
#                                                "Sep", "Oct", "Nov", "Dec"))
#orders_years <- factor(year(months.lub))

months_pl <- substr(months.lub, 1, 7)
months_pl <- factor(months_pl)
months_pl


most_orders_months <- table(months_pl)
rownames(most_orders_months) <- c(1:24)
most_orders_months



## ----------- ##
#* @get /ordersmonth
#* @serializer unboxedJSON
ordersmonth <- function() {
  df=as.data.frame(most_orders_months_2017)
  colnames(df)<-c("x", "y")
  return(list('response' = df))
}



###
# Average price per month -> try to find sale event

# 5. Orders by freight price
# freight_prices <- sort(table(products_orders$price), decreasing = T)
# ylab = "Number of orders", xlab = "Price order interval"
# ylab = "Number of orders", xlab = "Full payment of orders interval (Payment values)"
backup <- products_orders$price
freight_prices_2 <- cut(products_orders$price, breaks = c(10, 30, 50, 70, 100, 200))
freight_prices <- aggregate(products_orders$price, list(freight_prices_2), function(X) length(unique(X)))
## ----------- ##
#* @get /ordersprice
#* @serializer unboxedJSON
ordersprice <- function() {
  df=as.data.frame(freight_prices)
  colnames(df)<-c("x", "y")
  return(list('response' = df))
}

products_payments  = merge(products_orders, OrderPayments, by="order_id")
payment_values_2 <- cut(products_payments$payment_value, breaks = c(10, 30, 50, 70, 100, 200, 300))
payment_values <- aggregate(products_payments$payment_value, list(payment_values_2), function(X) length(unique(X)))
## ----------- ##
#* @get /orderspayment
#* @serializer unboxedJSON
orderspayment <- function() {
  df=as.data.frame(payment_values)
  colnames(df)<-c("x", "y")
  return(list('response' = df))
}


# 6. Delivery times
# ylab = "Number of orders", xlab = "Delivery time interval (days)"
purchase.lub = ymd_hms(products_orders$order_purchase_timestamp)
delivery.lub = ymd_hms(products_orders$order_delivered_customer_date)
diff_in_days = difftime(delivery.lub, purchase.lub, units = "days")
diff_in_days <- na.omit(diff_in_days)
diff_in_days_2 <- cut(as.numeric(diff_in_days), breaks = c(1, 5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100))
deliverytimes <- aggregate(diff_in_days, list(diff_in_days_2), function(X) length(unique(X)))
## ----------- ##
#* @get /ordersdelivery
#* @serializer unboxedJSON
ordersdelivery <- function() {
  df=as.data.frame(deliverytimes)
  colnames(df)<-c("x", "y")
  return(list('response' = df))
}


### Check review scores
reviews_orders = merge(AllOrders, OrderReviews, by="order_id")
summary(reviews_orders)
aux1 = merge(reviews_orders, OrderItems, by="order_id")
aux2 = merge(aux1, Products, by="product_id")
reviews_orders_products_eng = merge(aux2, ProductsTranslation, by="product_category_name")
###
# Connections between review score and product/shipping/order time/price ...

# 1. Review score
# xlab = "Review Score", ylab = "Number of orders"
# x = as.numeric(reviews_orders_products_eng$review_score)
## ----------- ##
#* @get /reviewscores
#* @serializer unboxedJSON
reviewscores <- function() {
  a <- table(as.numeric(reviews_orders_products_eng$review_score))
  a <- as.data.frame(a)
  colnames(a)<-c("x", "y")
  return(list('response' = a))
}

# 2. Products review scores
# ylab = "Review Score", xlab = "Last top 10 Products"
# ylab = "Review Score", xlab = "Top 10 Products"
product_review <- aggregate(reviews_orders_products_eng$review_score, 
                            by=list(Category=reviews_orders_products_eng$product_category_name_english),
                            FUN=mean)
lasttop10 = as.data.frame(product_review[order(product_review$x),])
top10 = as.data.frame(product_review[order(product_review$x, decreasing = TRUE),])
## ----------- ##
#* @get /reviewsproduct
#* @serializer unboxedJSON
reviewsproduct <- function() {
  # colnames(lasttop10)<-c("product", "review")
  # lasttop10 and top10 are the same arrays only ordered differently. try to order it in reverse in semiotic
  colnames(top10)<-c("x", "y")
  return(list('response' = top10))
}


# 3. Payment_value 
# ylab = "Payment value", xlab = "Last top 10 Products"
# ylab = "Payment value", xlab = "Top 10 Products"
reviews_orders_products_eng = merge(reviews_orders_products_eng, OrderPayments, by="order_id")
payment_review <- aggregate(reviews_orders_products_eng$payment_value, 
                            by=list(Category=reviews_orders_products_eng$product_category_name_english),
                            FUN=mean)
lasttop10_pr = data.frame(payment_review[order(payment_review$x),])
top10_pr = data.frame(payment_review[order(payment_review$x, decreasing = TRUE),])
## ----------- ##
#* @get /paymentproduct
#* @serializer unboxedJSON
paymentproduct <- function() {
  # lasttop10_pr and top10_pr are the same arrays only ordered differently. try to order it in reverse in semiotic
  colnames(top10_pr)<-c("x", "y")
  return(list('response' = top10_pr))
}


# 3.2 Payment review
# ylab = "Average payment value", xlab = "Score"
payment_review_2 <- aggregate(reviews_orders_products_eng$payment_value, 
                              by=list(Category=reviews_orders_products_eng$review_score), 
                              FUN=mean)
payment_review_2 = data.frame(payment_review_2[order(payment_review_2$x),])
## ----------- ##
#* @get /reviewpayment
#* @serializer unboxedJSON
reviewpayment <- function() {
  df=as.data.frame(payment_review_2)
  colnames(df)<-c("x", "y")
  return(list('response' = df))
}

# 4. Delivery times
# ylab = "Average delivery times (days)", xlab = "Score"
get_deliverytimes <- function(purchase, delivery)
{
  dpurchase.lub = ymd_hms(purchase)
  delivery.lub = ymd_hms(delivery)
  diff_in_days = difftime(delivery.lub, purchase.lub, units = "days")
  return(diff_in_days)
}

### check this !!!
deliverytimes_review = subset(reviews_orders_products_eng, select=c("order_id", "review_score", "order_purchase_timestamp", "order_delivered_customer_date"))
purchase.lub = ymd_hms(deliverytimes_review$order_purchase_timestamp)
delivery.lub = ymd_hms(deliverytimes_review$order_delivered_customer_date)
diff_in_days = difftime(delivery.lub, purchase.lub, units = "days")
deliverytimes_review$deliverytime_diff <- NA
deliverytimes_review$deliverytime_diff <- as.vector(diff_in_days)
deliverytimes_review$deliverytime_diff[is.na(deliverytimes_review$deliverytime_diff)] <- 0
deliverytimes_review$deliverytime_diff[is.nan(deliverytimes_review$deliverytime_diff)] <- 0
# mean(deliverytimes_review$deliverytime_diff)
deliverytimes_review_pl <- aggregate(deliverytimes_review$deliverytime_diff, 
                                     by=list(Category=deliverytimes_review$review_score), 
                                     FUN=mean)

deliverytimes_review_pl = as.data.frame(deliverytimes_review_pl[order(deliverytimes_review_pl$x),])
# deliverytimes_review_pl <- as.matrix(deliverytimes_review_pl)
## ----------- ##
#* @get /deliveryreview
#* @serializer unboxedJSON
deliveryreview <- function() {
  df=as.data.frame(deliverytimes_review_pl)
  colnames(df)<-c("x", "y")
  return(list('response' = df))
}


## ----------- ##
#* @get /deliverytimescount
#* @serializer unboxedJSON
deliveryreview <- function() {
  deliverytimes_review_pl <- aggregate(deliverytimes_review$deliverytime_diff, 
                                       by=list(Category=deliverytimes_review$review_score), 
                                       FUN=mean)
  
  deliverytimes_review_pl = as.data.frame(deliverytimes_review_pl[order(deliverytimes_review_pl$x),])
  
  df=as.data.frame(deliverytimes_review_pl)
  colnames(df)<-c("x", "y")
  return(list('response' = df))
}


# 5. Seller
# ylab = "Review Score", xlab = "Last top 50 Sellers"
# ylab = "Review Score", xlab = "Top 50 Sellers"
seller_review <- aggregate(reviews_orders_products_eng$review_score, 
                           by=list(Category=reviews_orders_products_eng$seller_id),
                           FUN=mean)
lasttop10_sr = data.frame(seller_review[order(seller_review$x),])
top10_sr = data.frame(seller_review[order(seller_review$x, decreasing = TRUE),])
# lasttop10_sr <- as.matrix(lasttop10_sr)
# top10_sr <- as.matrix(top10_sr)
## ----------- ##
#* @get /scoresellers
#* @serializer unboxedJSON
scoresellers <- function() {
  # order in semiotic
  df=as.data.frame(top10_sr)
  colnames(df)<-c("x", "y")
  return(list('response' = df))
}

# 5.1 Top sellers by number of orders
orders_products_eng_seller = merge(reviews_orders_products_eng, Sellers, by="seller_id")
most_orders_states <- table(orders_products_eng_seller$seller_state)
most_orders_states
most_orders_states_desc <- sort(most_orders_states, decreasing = TRUE)


most_orders_cities <- table(orders_products_eng_seller$seller_city)
most_orders_cities
most_orders_cities_desc <- sort(most_orders_cities, decreasing = TRUE)

## ----------- ##
#* @get /sellerstates
#* @serializer unboxedJSON
sellerstates <- function() {
  df=as.data.frame(most_orders_states_desc)
  colnames(df)<-c("x", "y")
  return(list('response' = df))
}

## ----------- ##
#* @get /sellercities
#* @serializer unboxedJSON
sellercities <- function() {
  df=as.data.frame(most_orders_cities_desc)
  colnames(df)<-c("x", "y")
  return(list('response' = df))
}

# 5.2 Seller cities
# ylab = "Review Score", xlab = "Last top 50 Sellers Cities"
# ylab = "Review Score", xlab = "Top 50 Sellers Cities"
reviews_orders_products_eng_seller = merge(reviews_orders_products_eng, Sellers, by="seller_id")
seller_review_city <- aggregate(reviews_orders_products_eng_seller$review_score, 
                                by=list(Category=reviews_orders_products_eng_seller$seller_city),
                                FUN=mean)
lasttop10_sr2 = data.frame(seller_review_city[order(seller_review_city$x),])
top10_sr2 = data.frame(seller_review_city[order(seller_review_city$x, decreasing = TRUE),])
# lasttop10_sr2 <- as.matrix(lasttop10_sr2)
# top10_sr2 <- as.matrix(top10_sr2)
## ----------- ##
#* @get /scorecities
#* @serializer unboxedJSON
scorecities <- function() {
  # order in semiotic
  df=as.data.frame(top10_sr2)
  colnames(df)<-c("x", "y")
  return(list('response' = df))
}


# 6. Customer
# nicest customers? -> would be nice to check for each customer, what they ordered, in what time it arrived, the total value of payment
# ylab = "Review Score", xlab = "Average score given by customer"
# ylab = "Review Score", xlab = "Average score given by customer"
customer_review <- aggregate(reviews_orders_products_eng$review_score, 
                             by=list(Category=reviews_orders_products_eng$customer_id),
                             FUN=mean)
lasttop10_cr = data.frame(customer_review[order(customer_review$x),])
top10_cr = data.frame(customer_review[order(customer_review$x, decreasing = TRUE),])
# lasttop10_cr <- as.matrix(lasttop10_cr)
# top10_cr <- as.matrix(top10_cr)
## ----------- ##
#* @get /customerscore
#* @serializer unboxedJSON
customerscore <- function() {
  # order in semiotic
  df=as.data.frame(top10_cr)
  colnames(df)<-c("x", "y")
  return(list('response' = df))
}


# 6.1 Averag score given by customer from different cities (Are certain customers probable to give certain reviews more?)
# ylab = "Review Score", xlab = "Average score given by customer from certain city"
# ylab = "Review Score", xlab = "Average score given by customer from certain city"
reviews_orders_products_eng_customer = merge(reviews_orders_products_eng, Customers, by="customer_id")
customer_review2 <- aggregate(reviews_orders_products_eng_customer$review_score, 
                              by=list(Category=reviews_orders_products_eng_customer$customer_city),
                              FUN=mean)
lasttop10_cr2 = data.frame(customer_review2[order(customer_review2$x),])
top10_cr2 = data.frame(customer_review2[order(customer_review2$x, decreasing = TRUE),])
# lasttop10_cr2 <- as.matrix(lasttop10_cr2)
# top10_cr2 <- as.matrix(top10_cr2)
## ----------- ##
#* @get /cityscore
#* @serializer unboxedJSON
cityscore <- function() {
  # order in semiotic
  df=as.data.frame(top10_cr2)
  colnames(df)<-c("y", "x")
  return(list('response' = df))
}

# 6.2 Top customers states and cities by number of orders

orders_products_eng_customer = merge(reviews_orders_products_eng, Customers, by="customer_id")
most_orders_customers_states <- table(orders_products_eng_customer$customer_state)
most_orders_customers_states
most_orders_customers_states_desc <- sort(most_orders_customers_states, decreasing = TRUE)

most_orders_customers_cities <- table(reviews_orders_products_eng_customer$customer_city)
most_orders_customers_cities
most_orders_customers_cities_desc <- sort(most_orders_customers_cities, decreasing = TRUE)

## ----------- ##
#* @get /customerstates
#* @serializer unboxedJSON
customerstates <- function() {
  df=as.data.frame(most_orders_customers_states_desc)
  colnames(df)<-c("x", "y")
  return(list('response' = df))
}

## ----------- ##
#* @get /customercities
#* @serializer unboxedJSON
customercities <- function() {
  df=as.data.frame(most_orders_customers_cities_desc)
  colnames(df)<-c("x", "y")
  return(list('response' = df))
}

