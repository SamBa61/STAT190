# clear workspace
rm(list = ls())

# libraries
library(dplyr) # for
library(readr) # for

# read in data
# combine separate .csv files from data_raw
demand_all_data <- list.files(path="/Users/sambasala/Desktop/STAT 190/DataCapstone/data_raw", full.names = TRUE) %>% 
  lapply(read_csv) %>% 
  bind_rows 