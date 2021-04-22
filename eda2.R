library(funModeling) 
library(tidyverse) 
library(Hmisc)
library(DataExplorer)

require(lubridate)
require(dplyr)

Customers <- read.csv(file="dataset/olist_customers_dataset.csv", header=TRUE, sep=",")
Geolocation <- read.csv(file="dataset/olist_geolocation_dataset.csv", header=TRUE, sep=",")
OrderItems <- read.csv(file="dataset/olist_order_items_dataset.csv", header=TRUE, sep=",")
OrderPayments <- read.csv(file="dataset/olist_order_payments_dataset.csv", header=TRUE, sep=",")
OrderReviews <- read.csv(file="dataset/olist_order_reviews_dataset.csv", header=TRUE, sep=",")
AllOrders <- read.csv(file="dataset/olist_orders_dataset.csv", header=TRUE, sep=",")
Products <- read.csv(file="dataset/olist_products_dataset.csv", header=TRUE, sep=",")
Sellers <- read.csv(file="dataset/olist_sellers_dataset.csv", header=TRUE, sep=",")
ProductsTranslation <- read.csv(file="dataset/product_category_name_translation.csv", header=TRUE, sep=",")

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

aux1 = merge(AllOrders, OrderReviews, by="order_id")
summary(aux1)
aux2 = merge(aux1, OrderPayments, by="order_id")
summary(aux2)
aux3 = merge(aux2, OrderItems, by="order_id")
summary(aux3)
aux4 = merge(aux3, Products, by="product_id")
summary(aux4)
aux5 = merge(aux4, Customers, by="customer_id")
summary(aux5)
aux6 = merge(aux5, Sellers, by="seller_id")
summary(aux6)

colnames(ProductsTranslation)[1] <- "product_category_name"

AllData = merge(aux6, ProductsTranslation, by="product_category_name")
summary(AllData)

str(AllData)
AllData_D <- subset(AllData, select = -c(seller_id, customer_id, product_id, order_id, review_id, 
                                         review_comment_title, review_comment_message, review_creation_date,
                                         review_answer_timestamp, payment_sequential, order_item_id,
                                         product_name_lenght, product_description_lenght, product_photos_qty,
                                         customer_unique_id, customer_zip_code_prefix, seller_zip_code_prefix,
                                         product_category_name))
str(AllData_D)

AllData_D$order_purchase_timestamp = as.POSIXct(AllData_D$order_purchase_timestamp, format = "%Y-%m-%d %H:%M:%S")
AllData_D$order_approved_at = as.POSIXct(AllData_D$order_approved_at, format = "%Y-%m-%d %H:%M:%S")
AllData_D$order_delivered_carrier_date = as.POSIXct(AllData_D$order_delivered_carrier_date, format = "%Y-%m-%d %H:%M:%S")
AllData_D$order_delivered_customer_date = as.POSIXct(AllData_D$order_delivered_customer_date, format = "%Y-%m-%d %H:%M:%S")
AllData_D$order_estimated_delivery_date = as.POSIXct(AllData_D$order_estimated_delivery_date, format = "%Y-%m-%d %H:%M:%S")
AllData_D$shipping_limit_date = as.POSIXct(AllData_D$shipping_limit_date, format = "%Y-%m-%d %H:%M:%S")

str(AllData_D)

# purchase.lub = ymd_hms(AllData_D$order_purchase_timestamp)
# delivery.lub = ymd_hms(AllData_D$order_delivered_customer_date)
# 
# diff_in_days = difftime(delivery.lub, purchase.lub, units = "days")
# 
# AllData_D$deliverytime_diff <- NA
# AllData_D$deliverytime_diff <- as.vector(diff_in_days)

AllData_D$diff_time_days <- apply(AllData_D[,c('order_purchase_timestamp', 'order_delivered_customer_date')],
                                  1,
                                  function(x) { 
                                    purchase.lub = ymd_hms(x[1])
                                    delivery.lub = ymd_hms(x[2])
                                    diff_in_days = difftime(delivery.lub, purchase.lub, units = "days")
                                    return(diff_in_days)
                                  })

AllData_D <- subset(AllData_D, select = -c(order_purchase_timestamp, order_delivered_customer_date))

nrow(AllData_D)
AllData_D <- na.omit(AllData_D)
nrow(AllData_D)

str(AllData_D)

glimpse(AllData_D)
df_status(AllData_D)
freq(AllData_D)
plot_num(AllData_D)
profiling_num(AllData_D)
describe(AllData_D)


plotar(data = AllData_D, target = "review_score", plot_type = "histdens")
plotar(data = AllData_D, target = "review_score", plot_type = "boxplot")


plot_str(AllData_D)
plot_histogram(AllData_D)
plot_density(AllData_D)

plot_correlation(type="continuous", data = AllData_D, 'review_score')
plot_correlation(type="discrete", data = AllData_D, 'review_score')

str(AllData_D)
aux_alldata <-  subset(AllData_D, select = -c(order_approved_at, order_delivered_carrier_date,
                                            order_estimated_delivery_date, shipping_limit_date,
                                            customer_city, seller_city,
                                            product_category_name_english, customer_state, seller_state))
str(aux_alldata)
plot_correlation(type="discrete", data = aux_alldata, 'review_score')




