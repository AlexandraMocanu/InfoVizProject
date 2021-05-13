## main.R ##
## ------ ##
library(plumber)
r <- plumb("functions_eda1.R")
r$run(port=3001)
