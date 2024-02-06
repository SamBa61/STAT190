# clear workspace
rm(list = ls())

# load in dataset
outages_2024 <- read.csv("outages_2024.csv", stringsAsFactors = FALSE)
