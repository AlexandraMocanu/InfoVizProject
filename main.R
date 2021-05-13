## main.R ##
## ------ ##
library(plumber)

root <- Plumber$new()

a <- Plumber$new("functions_eda1.R")
root$mount("/eda1", a)

b <- Plumber$new("functions_customeda.R")
root$mount("/custom", b)

root$run(port=3001, swagger=TRUE, debug=TRUE)

#r <- plumb("")
#r$run(port=3001)
