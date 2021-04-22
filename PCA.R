str(AllData)
library(factoextra)
library(corrplot)
library(RColorBrewer)
library(ggcorrplot)
library(ggplot2)
library(reshape2)
library(caret)

#new dataframe with relevant columns for analysis
AnalysisData <- subset(AllData, select = c(customer_unique_id, order_item_id, order_status,
                                         payment_type, payment_installments, payment_value, price, freight_value,
                                         product_category_name_english, product_name_length, product_description_length, product_photos_qty, product_weight_g,
                                         product_length_cm, product_height_cm, product_width_cm, customer_city, customer_state,
                                         seller_city, seller_state, review_score, review_comment_message))

AllData$order_purchase_timestamp = as.POSIXct(AllData$order_purchase_timestamp, format = "%Y-%m-%d %H:%M:%S")
AllData$order_delivered_customer_date = as.POSIXct(AllData$order_delivered_customer_date, format = "%Y-%m-%d %H:%M:%S")

#compute number of delivery days (between purchase and delivery date)
AnalysisData$delivery_days <- as.Date(AllData$order_delivered_customer_date, format="%Y/%m/%d") - as.Date(AllData$order_purchase_timestamp, format="%Y/%m/%d")

str(AnalysisData)

#number of unique values
length(unique(AnalysisData[["order_status"]]))

AnalysisDataNumerical <- AnalysisData

#encode categorical columns
AnalysisDataNumerical$order_status <- as.numeric(factor(AnalysisData$order_status))
AnalysisDataNumerical$customer_unique_id <- as.numeric(factor(AnalysisData$customer_unique_id))
AnalysisDataNumerical$payment_type <- as.numeric(factor(AnalysisData$payment_type))
AnalysisDataNumerical$product_category_name_english <- as.numeric(factor(AnalysisData$product_category_name_english))
AnalysisDataNumerical$customer_city <- as.numeric(factor(AnalysisData$customer_city))
AnalysisDataNumerical$customer_state <- as.numeric(factor(AnalysisData$customer_state))
AnalysisDataNumerical$seller_city <- as.numeric(factor(AnalysisData$seller_city))
AnalysisDataNumerical$seller_state <- as.numeric(factor(AnalysisData$seller_state))
AnalysisDataNumerical$delivery_days <- as.numeric(AnalysisDataNumerical$delivery_days)

#review_comment_message is 0 if previously blank, 1 otherwise
AnalysisDataNumerical$review_comment_message <- ifelse(AnalysisDataNumerical$review_comment_message=="", 0, 1)

#remove rows containing NA values
AnalysisDataNumerical <- na.omit(AnalysisDataNumerical)


# Creating correlation plots 
cormat <- round(cor(AnalysisDataNumerical), 2)
ggcorrplot(cormat, hc.order = TRUE, type = "full", outline.color = "white")

cormat <- cor(AnalysisDataNumerical)

col<- colorRampPalette(c("blue", "white", "red"))(20)
heatmap(x = cormat, col = col, symm = TRUE)

ggplot(melt(cormat), aes(Var1, Var2, fill = value)) +
  geom_tile() +
  scale_fill_gradient2(low="blue", mid="white", high="red") +
  coord_equal()

#PCA

AnalysisDataNumerical.pca <- prcomp(AnalysisDataNumerical, center = TRUE, scale = TRUE)

summary(AnalysisDataNumerical.pca)

# Screeplot
var <-  AnalysisDataNumerical.pca$sdev ^ 2
pve <- var / sum(var)
plot(pve, xlab = "Principal Component", ylab = "Proportion of Variance Explained", ylim = c(0,1), type = 'b')

fviz_eig(AnalysisDataNumerical.pca)

# Cumulative PVE plot
plot(cumsum(pve), xlab = "Principal Component", ylab = "Cumulative Proportion of Variance Explained", ylim =c(0,1), type = 'b')

#Graph of variables. Positive correlated variables point to the same side of the plot. 
#Negative correlated variables point to opposite sides of the graph.
fviz_pca_var(AnalysisDataNumerical.pca,
             col.var = "contrib", # Color by contributions to the PC
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             repel = TRUE     # Avoid text overlapping
)

######################################################################
#REDUCE NUMBER OF COLUMNS
DataReduced.pca <- prcomp(DataReduced, center = TRUE, scale = TRUE)

summary(DataReduced.pca)

# Screeplot
var <-  DataReduced.pca$sdev ^ 2
pve <- var / sum(var)
plot(pve, xlab = "Principal Component", ylab = "Proportion of Variance Explained", ylim = c(0,1), type = 'b')

fviz_eig(DataReduced.pca)

# Cumulative PVE plot
plot(cumsum(pve), xlab = "Principal Component", ylab = "Cumulative Proportion of Variance Explained", ylim =c(0,1), type = 'b')

fviz_pca_var(DataReduced.pca,
             col.var = "contrib", # Color by contributions to the PC
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             repel = TRUE)    # Avoid text overlapping

#Loadings rotation
pca.loadings <- DataReduced.pca$rotation

rot_loading <- varimax(DataReduced.pca$rotation[, 1:3])
rot_loading

#on full set
rot_loading <- varimax(AnalysisDataNumerical.pca$rotation[, 1:3])
rot_loading

# dummify the data
dmy <- dummyVars(" ~ payment_type", data = AnalysisData)
transformed <- data.frame(predict(dmy, newdata = AnalysisData))
setwd('C:/Users/Delia/Desktop/MASTER/EDA/PROJECT')
dmy