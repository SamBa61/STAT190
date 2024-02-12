# clear workspace
rm(list = ls())

# libraries
library(rvest)
library(dplyr)

#####################################################################################################

# lists
CustServiceInterrupt <- list()
TransmissionInterrupt <- list()
TransformerInterrupt <- list()

# only doing 2018-2024 to keep things current

for (year in 2018:2024) {
  
  url <- paste0("https://transmission.bpa.gov/Business/Operations/Outages/OutagesCY", year, ".htm")
  outage_data <- read_html(url) %>%
    html_table()
  
  Sys.sleep(2) # delay between requests
  
  print(paste('scraping data for year: ', year))
  
  i <- length(CustServiceInterrupt) + 1
  
  if (length(outage_data) >= 3)
  {
    CustServiceInterrupt[[i]] <- outage_data[[1]]
    TransmissionInterrupt[[i]] <- outage_data[[2]]
    TransformerInterrupt[[i]] <- outage_data[[3]]
  }
  
  else if (length(outage_data) == 2)
  {
    CustServiceInterrupt[[i]] <- outage_data[[1]]
    TransmissionInterrupt[[i]] <- outage_data[[2]]
    message(paste("no data found for TransformerInterrupt", year))
  }
  
  else
  {
    CustServiceInterrupt[[i]] <- outage_data[[1]]
    message(paste("no data found for TransmissionInterrupt and TransformerInterrupt", year))
  }
  
}

# combining into one DataFrame
Final_CustServiceInterrupt <- data.table::rbindlist(CustServiceInterrupt, fill = T)
Final_TransmissionInterrupt <- data.table::rbindlist(TransmissionInterrupt, fill = T)
Final_TransformerInterrupt <- data.table::rbindlist(TransformerInterrupt, fill = T)
