# clear workspace
rm(list = ls())

# libraries
library(dplyr)
library(readr)

# read in data
# large .xlsx for region
# API pull

# combine separate .csv files
demand_all_data <- list.files(path="/Users/sambasala/Desktop/STAT 190/data", full.names = TRUE) %>% 
  lapply(read_csv) %>% 
  bind_rows 

# need to include DIBA!
demand_all_data_final <- subset(demand_all_data, select = -c(1, 3:6, 10:41))

colnames(demand_all_data_final) <- c("Date", "Demand_MW", "Net_Generation_MW",
                                     "Total_Interchange_MW", "Region")

#write_file()
