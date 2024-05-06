# clear workspace

rm(list = ls())

##################################################################################################################

# load in libraries

library(dplyr) # for data manipulation and pipelining
library(readr) # for reading .csv files easily

##################################################################################################################

# read in data by combining .csv files from data_raw github folder

demand_all_data <- list.files(path="data_raw", full.names = TRUE) %>% 
  lapply(read_csv) %>% 
  bind_rows 