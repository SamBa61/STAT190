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

####################################################################################################

library(httr)   # For making HTTP requests
library(jsonlite)  # For handling JSON data

# Define API endpoint URL
api_url <- "https://api.eia.gov/v2/electricity/rto/daily-region-data/data/"

# Make a GET request to the API
response <- GET(api_url)

# Check if the request was successful (status code 200)
  # Parse JSON response
data <- content(response, "text")  # Assuming the response is JSON
parsed_data <- fromJSON(data)
  
  # Check the structure of the parsed data
str(parsed_data)
  
  # Convert to data frame
df <- as.data.frame(parsed_data)
  

#write_file()
