require(lubridate)
require(dplyr)
library(RColorBrewer)

Customers <- read.csv(file="../../whole_dataset/olist_customers_dataset.csv", header=TRUE, sep=",")
Geolocation <- read.csv(file="../../whole_dataset/olist_geolocation_dataset.csv", header=TRUE, sep=",")
OrderItems <- read.csv(file="../../whole_dataset/olist_order_items_dataset.csv", header=TRUE, sep=",")
OrderPayments <- read.csv(file="../../whole_dataset/olist_order_payments_dataset.csv", header=TRUE, sep=",")
OrderReviews <- read.csv(file="../../whole_dataset/olist_order_reviews_dataset.csv", header=TRUE, sep=",")
AllOrders <- read.csv(file="../../whole_dataset/olist_orders_dataset.csv", header=TRUE, sep=",")
Products <- read.csv(file="../../whole_dataset/olist_products_dataset.csv", header=TRUE, sep=",")
Sellers <- read.csv(file="../../whole_dataset/olist_sellers_dataset.csv", header=TRUE, sep=",")
ProductsTranslation <- read.csv(file="../../whole_dataset/product_category_name_translation.csv", header=TRUE, sep=",")

summary(Customers)
summary(Geolocation)
summary(OrderItems)
summary(OrderPayments)
summary(OrderReviews)
summary(AllOrders)
summary(Products)
summary(Sellers)


colnames(ProductsTranslation)[colnames(ProductsTranslation)=="?..product_category_name"] <- "product_category_name"
summary(ProductsTranslation)

### Check orders patterns
# 1. Orders by city
city_orders = merge(Customers, AllOrders, by="customer_id")
summary(city_orders)

most_orders_city <- sort(table(city_orders$customer_city), decreasing=T)
most_orders_city

barplot(most_orders_city[0:10], cex.names = 0.7,
        col=brewer.pal(10, "Paired"),
        xlab = "City of delivery/order (top 10)", ylab = "Number of orders",
        beside=TRUE, ylim=range(pretty(c(0, most_orders_city[0:10]))))

# 2. Orders by product type 
products_orders = merge(AllOrders, OrderItems, by="order_id")
summary(products_orders)

products_orders_names = merge(products_orders, Products, by="product_id")
products_orders_names_eng = merge(products_orders_names, ProductsTranslation, by="product_category_name")
products_orders_names_eng

most_orders_type <- sort(table(products_orders_names_eng$product_category_name_english), decreasing = T)
most_orders_type

barplot(most_orders_type[0:10], cex.names = 0.65, las=1, 
        col=brewer.pal(10, "Paired"),
        xlab = "Product category (top 10)", ylab = "Number of orders",
        beside=TRUE, ylim=range(pretty(c(0, most_orders_type[0:10]))))


# 3. Orders by year
summary(products_orders)
years.lub = ymd_hms(products_orders$order_purchase_timestamp)
most_orders_years <- table(year(years.lub))
most_orders_years

barplot(most_orders_years, cex.names = 0.7,
        col=brewer.pal(3, "Set2"),
        xlab = "Year order", ylab = "Number of orders",
        beside=TRUE, ylim=range(pretty(c(0, most_orders_years))))


# 4. Orders by month
summary(products_orders)
months.lub = ymd_hms(products_orders$order_purchase_timestamp)
months_pl <- factor(month(months.lub), labels = c("Jan", "Feb", "Mar", "Apr",
                                           "May", "Jun", "Jul", "Aug",
                                           "Sep", "Oct", "Nov", "Dec"))
# most_orders_months_t <- table(month.abb[month(months.lub)])
# most_orders_months_t
most_orders_months <- table(months_pl)
most_orders_months

barplot(most_orders_months, cex.names = 0.7,
        col=brewer.pal(10, "Paired"),
        xlab = "Order month", ylab = "Number of orders",
        beside=TRUE, ylim=range(pretty(c(0, most_orders_months))))

###
# Average price per month -> try to find sale event

# 5. Orders by freight price
# freight_prices <- sort(table(products_orders$price), decreasing = T)
# freight_prices
# barplot(freight_prices[0:20], cex.names = 0.7)

backup <- products_orders$price
freight_prices_2 <- cut(products_orders$price, breaks = c(10, 30, 50, 70, 100, 200))
freight_prices <- tapply(products_orders$price, freight_prices_2, function(X) length(unique(X)))
#freight_prices = aggregate(products_orders$price, list(freight_prices_2), function(X) length(unique(X)))
freight_prices
barplot(freight_prices, cex.names = 0.9, 
        col=brewer.pal(10, "Paired"),
        ylab = "Number of orders", xlab = "Price order interval",
        beside=TRUE, ylim=range(pretty(c(0, freight_prices))))

products_payments  = merge(products_orders, OrderPayments, by="order_id")
payment_values_2 <- cut(products_payments$payment_value, breaks = c(10, 30, 50, 70, 100, 200, 300))
payment_values <- tapply(products_payments$payment_value, payment_values_2, function(X) length(unique(X)))
payment_values
barplot(payment_values, cex.names = 0.9, 
        col=brewer.pal(10, "Paired"),
        ylab = "Number of orders", xlab = "Full payment of orders interval (Payment values)",
        beside=TRUE, ylim=range(pretty(c(0, payment_values))))


# 6. Delivery times
summary(products_orders)

purchase.lub = ymd_hms(products_orders$order_purchase_timestamp)
delivery.lub = ymd_hms(products_orders$order_delivered_customer_date)

diff_in_days = difftime(delivery.lub, purchase.lub, units = "days")
diff_in_days <- na.omit(diff_in_days)

diff_in_days_2 <- cut(as.numeric(diff_in_days), breaks = c(1, 5, 10, 20, 30, 40, 50, 100))
deliverytimes <- tapply(diff_in_days, diff_in_days_2, function(X) length(unique(X)))
deliverytimes
barplot(deliverytimes, cex.names = 0.9, 
        col=brewer.pal(10, "Paired"),
        ylab = "Number of orders", xlab = "Delivery time interval (days)",
        beside=TRUE, ylim=range(pretty(c(0, deliverytimes))))


### Chech review scores
reviews_orders = merge(AllOrders, OrderReviews, by="order_id")
summary(reviews_orders)
aux1 = merge(reviews_orders, OrderItems, by="order_id")
aux2 = merge(aux1, Products, by="product_id")
reviews_orders_products_eng = merge(aux2, ProductsTranslation, by="product_category_name")
summary(reviews_orders_products_eng)


###
# Connections between review score and product/shipping/order time/price ...

# 1. Review score
hist(x = as.numeric(reviews_orders_products_eng$review_score),
     col=brewer.pal(10, "Set2"),
     xlab = "Review Score", ylab = "Number of orders", main = {title = "Review scores"})


# 2. Products review scores
product_review <- aggregate(reviews_orders_products_eng$review_score, 
                            by=list(Category=reviews_orders_products_eng$product_category_name_english),
                            FUN=mean)
product_review
lasttop10 = data.frame(product_review[order(product_review$x),], row.names = "Category")
top10 = data.frame(product_review[order(product_review$x, decreasing = TRUE),], row.names = "Category")
lasttop10 <- as.matrix(lasttop10)
lasttop10
top10 <- as.matrix(top10)
top10

barplot(lasttop10[0:10,], cex.names = 0.5,
        col=brewer.pal(10, "Paired"),
        ylab = "Review Score", xlab = "Last top 10 Products",  
        beside=TRUE, ylim=range(pretty(c(0, lasttop10[0:10]))))
barplot(top10[0:10,], cex.names = 0.5,
        col=brewer.pal(10, "Paired"),
        ylab = "Review Score", xlab = "Top 10 Products",  
        beside=TRUE, ylim=range(pretty(c(0, top10[0:10]))))


# 3. Payment_value 
reviews_orders_products_eng = merge(reviews_orders_products_eng, OrderPayments, by="order_id")
reviews_orders_products_eng
payment_review <- aggregate(reviews_orders_products_eng$payment_value, 
                            by=list(Category=reviews_orders_products_eng$product_category_name_english),
                            FUN=mean)
payment_review

lasttop10_pr = data.frame(payment_review[order(payment_review$x),], row.names = "Category")
top10_pr = data.frame(payment_review[order(payment_review$x, decreasing = TRUE),], row.names = "Category")
lasttop10_pr <- as.matrix(lasttop10_pr)
lasttop10_pr
top10_pr <- as.matrix(top10_pr)
top10_pr

barplot(lasttop10_pr[0:10,], cex.names = 0.5,
        col=brewer.pal(10, "Paired"),
        ylab = "Payment value", xlab = "Last top 10 Products",  
        beside=TRUE, ylim=range(pretty(c(0, lasttop10_pr[0:10]))))
barplot(top10_pr[0:10,], cex.names = 0.44,
        col=brewer.pal(10, "Paired"),
        ylab = "Payment value", xlab = "Top 10 Products",  
        beside=TRUE, ylim=range(pretty(c(0, top10_pr[0:10]))))


payment_review_2 <- aggregate(reviews_orders_products_eng$payment_value, 
                              by=list(Category=reviews_orders_products_eng$review_score), 
                              FUN=mean)
payment_review_2

payment_review_2 = data.frame(payment_review_2[order(payment_review_2$x),], row.names = "Category")
payment_review_2 <- as.matrix(payment_review_2)
payment_review_2

barplot(payment_review_2[,], cex.names = 0.8,
        col=brewer.pal(10, "Paired"),
        ylab = "Average payment value", xlab = "Score",  
        beside=TRUE, ylim=range(pretty(c(0, payment_review_2))))

# 4. Delivery times

# purchase.lub = ymd_hms(reviews_orders_products_eng$order_purchase_timestamp)
# delivery.lub = ymd_hms(reviews_orders_products_eng$order_delivered_customer_date)
# 
# diff_in_days = difftime(delivery.lub, purchase.lub, units = "days")
# diff_in_days <- na.omit(diff_in_days)
# 
# diff_in_days_2 <- cut(as.numeric(diff_in_days), breaks = c(1, 5, 10, 20, 30, 40, 50, 100))
# deliverytimes <- tapply(diff_in_days, diff_in_days_2, function(X) length(unique(X)))
# deliverytimes

#function
get_deliverytimes <- function(purchase, delivery)
{
  dpurchase.lub = ymd_hms(purchase)
  delivery.lub = ymd_hms(delivery)
  diff_in_days = difftime(delivery.lub, purchase.lub, units = "days")
  return(diff_in_days)
}

summary(reviews_orders_products_eng)

### check this !!!
deliverytimes_review = subset(reviews_orders_products_eng, select=c("order_id", "review_score", "order_purchase_timestamp", "order_delivered_customer_date"))
# deliverytimes_review$order_purchase_timestamp <- NA
# deliverytimes_review$order_purchase_timestamp <- reviews_orders_products_eng$order_purchase_timestamp
# deliverytimes_review$order_delivered_customer_date <- NA
# deliverytimes_review$order_delivered_customer_date = reviews_orders_products_eng$order_delivered_customer_date
# deliverytimes_review$review_score <- NA
# deliverytimes_review$review_score = reviews_orders_products_eng$review_score

# deliverytimes_review$deliverytime_diff <- NA
# deliverytimes_review$deliverytime_diff <- mapply(get_deliverytimes, 
#                                                  deliverytimes_review$order_purchase_timestamp, 
#                                                  deliverytimes_review$order_delivered_customer_date)

deliverytimes_review

purchase.lub = ymd_hms(deliverytimes_review$order_purchase_timestamp)
delivery.lub = ymd_hms(deliverytimes_review$order_delivered_customer_date)

diff_in_days = difftime(delivery.lub, purchase.lub, units = "days")
#diff_in_days <- na.omit(diff_in_days)

deliverytimes_review$deliverytime_diff <- NA
deliverytimes_review$deliverytime_diff <- as.vector(diff_in_days)

summary(deliverytimes_review)
deliverytimes_review$deliverytime_diff[is.na(deliverytimes_review$deliverytime_diff)] <- 0
deliverytimes_review$deliverytime_diff[is.nan(deliverytimes_review$deliverytime_diff)] <- 0
mean(deliverytimes_review$deliverytime_diff)
deliverytimes_review$deliverytime_diff

deliverytimes_review_pl <- aggregate(deliverytimes_review$deliverytime_diff, 
                                     by=list(Category=deliverytimes_review$review_score), 
                                     FUN=mean)

deliverytimes_review_pl

deliverytimes_review_pl = data.frame(deliverytimes_review_pl[order(deliverytimes_review_pl$x),], row.names = "Category")
deliverytimes_review_pl <- as.matrix(deliverytimes_review_pl)
deliverytimes_review_pl

barplot(deliverytimes_review_pl[,], cex.names = 0.8,
        col=brewer.pal(10, "Paired"),
        ylab = "Average delivery times (days)", xlab = "Score",  
        beside=TRUE, ylim=range(pretty(c(0, deliverytimes_review_pl))))


# 5. Seller
seller_review <- aggregate(reviews_orders_products_eng$review_score, 
                            by=list(Category=reviews_orders_products_eng$seller_id),
                            FUN=mean)
seller_review
lasttop10_sr = data.frame(seller_review[order(seller_review$x),], row.names = "Category")
top10_sr = data.frame(seller_review[order(seller_review$x, decreasing = TRUE),], row.names = "Category")
lasttop10_sr <- as.matrix(lasttop10_sr)
lasttop10_sr
top10_sr <- as.matrix(top10_sr)
top10_sr

plot(seller_review)

barplot(lasttop10_sr[0:50,], cex.names = 0.6,
        col=brewer.pal(10, "Paired"),
        ylab = "Review Score", xlab = "Last top 50 Sellers",  
        beside=TRUE, ylim=range(pretty(c(0, lasttop10_sr[0:50]))))
barplot(top10_sr[0:50,], cex.names = 0.6,
        col=brewer.pal(10, "Paired"),
        ylab = "Review Score", xlab = "Top 50 Sellers",  
        beside=TRUE, ylim=range(pretty(c(0, top10_sr[0:50]))))


reviews_orders_products_eng_seller = merge(reviews_orders_products_eng, Sellers, by="seller_id")
summary(reviews_orders_products_eng_seller)

seller_review_city <- aggregate(reviews_orders_products_eng_seller$review_score, 
                           by=list(Category=reviews_orders_products_eng_seller$seller_city),
                           FUN=mean)
seller_review_city

lasttop10_sr2 = data.frame(seller_review_city[order(seller_review_city$x),], row.names = "Category")
top10_sr2 = data.frame(seller_review_city[order(seller_review_city$x, decreasing = TRUE),], row.names = "Category")
lasttop10_sr2 <- as.matrix(lasttop10_sr2)
lasttop10_sr2
top10_sr2 <- as.matrix(top10_sr2)
top10_sr2

plot(seller_review_city)

barplot(lasttop10_sr2[0:50,], cex.names = 0.6,
        col=brewer.pal(10, "Paired"),
        ylab = "Review Score", xlab = "Last top 50 Sellers Cities",  
        beside=TRUE, ylim=range(pretty(c(0, lasttop10_sr2[0:50]))))
barplot(top10_sr2[0:50,], cex.names = 0.6,
        col=brewer.pal(10, "Paired"),
        ylab = "Review Score", xlab = "Top 50 Sellers Cities",  
        beside=TRUE, ylim=range(pretty(c(0, top10_sr2[0:50]))))

# 6. Customer
customer_review <- aggregate(reviews_orders_products_eng$review_score, 
                           by=list(Category=reviews_orders_products_eng$customer_id),
                           FUN=mean)
customer_review
lasttop10_cr = data.frame(customer_review[order(customer_review$x),], row.names = "Category")
top10_cr = data.frame(customer_review[order(customer_review$x, decreasing = TRUE),], row.names = "Category")
lasttop10_cr <- as.matrix(lasttop10_cr)
lasttop10_cr
top10_cr <- as.matrix(top10_cr)
top10_cr

# plot(customer_review)

barplot(lasttop10_cr[0:50,], cex.names = 0.6,
        col=brewer.pal(10, "Paired"),
        ylab = "Review Score", xlab = "Average score given by customer",  
        beside=TRUE, ylim=range(pretty(c(0, lasttop10_cr[0:50]))))
barplot(top10_cr[0:50,], cex.names = 0.6,
        col=brewer.pal(10, "Paired"),
        ylab = "Review Score", xlab = "Average score given by customer",  
        beside=TRUE, ylim=range(pretty(c(0, top10_cr[0:50]))))



reviews_orders_products_eng_customer = merge(reviews_orders_products_eng, Customers, by="customer_id")
summary(reviews_orders_products_eng_customer)

customer_review2 <- aggregate(reviews_orders_products_eng_customer$review_score, 
                             by=list(Category=reviews_orders_products_eng_customer$customer_city),
                             FUN=mean)
customer_review2
lasttop10_cr2 = data.frame(customer_review2[order(customer_review2$x),], row.names = "Category")
top10_cr2 = data.frame(customer_review2[order(customer_review2$x, decreasing = TRUE),], row.names = "Category")
lasttop10_cr2 <- as.matrix(lasttop10_cr2)
lasttop10_cr2
top10_cr2 <- as.matrix(top10_cr2)
top10_cr2

# plot(customer_review)

barplot(lasttop10_cr2[0:50,], cex.names = 0.6,
        col=brewer.pal(10, "Paired"),
        ylab = "Review Score", xlab = "Average score given by customer from certain city",  
        beside=TRUE, ylim=range(pretty(c(0, lasttop10_cr2[0:50]))))
barplot(top10_cr2[0:50,], cex.names = 0.6,
        col=brewer.pal(10, "Paired"),
        ylab = "Review Score", xlab = "Average score given by customer from certain city",  
        beside=TRUE, ylim=range(pretty(c(0, top10_cr2[0:50]))))

