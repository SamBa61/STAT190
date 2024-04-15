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

# scraping loop 1999-2013

for (year in 1999:2013) {

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
CustServiceInterrupt_99_12 <- data.table::rbindlist(CustServiceInterrupt, fill = T)

Final_TransmissionInterrupt_99_13 <- data.table::rbindlist(TransmissionInterrupt, fill = T)

Final_TransformerInterrupt_99_13 <- data.table::rbindlist(TransformerInterrupt, fill = T)

#####################################################################################################

# scraping loop 2014

for (year in 2014:2014) {
  
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
CustServiceInterrupt_14 <- data.table::rbindlist(CustServiceInterrupt, fill = T)

Final_TransmissionInterrupt_14 <- data.table::rbindlist(TransmissionInterrupt, fill = T)

Final_TransformerInterrupt_14 <- data.table::rbindlist(TransformerInterrupt, fill = T)

#####################################################################################################

# scraping loop 2015

for (year in 2015:2015) {
  
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
CustServiceInterrupt_15 <- data.table::rbindlist(CustServiceInterrupt, fill = T)

Final_TransmissionInterrupt_15 <- data.table::rbindlist(TransmissionInterrupt, fill = T)

Final_TransformerInterrupt_15 <- data.table::rbindlist(TransformerInterrupt, fill = T)

#####################################################################################################

# scraping loop 2016-2017

for (year in 2016:2017) {
  
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
CustServiceInterrupt_99_12 <- data.table::rbindlist(CustServiceInterrupt, fill = T)

Final_TransmissionInterrupt_16_17 <- data.table::rbindlist(TransmissionInterrupt, fill = T)

Final_TransformerInterrupt_16_17 <- data.table::rbindlist(TransformerInterrupt, fill = T)

#####################################################################################################

# scraping loop 2018-2024

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
CustServiceInterrupt_18_24 <- data.table::rbindlist(CustServiceInterrupt, fill = T)

Final_TransmissionInterrupt_18_24 <- data.table::rbindlist(TransmissionInterrupt, fill = T)

Final_TransformerInterrupt_18_24 <- data.table::rbindlist(TransformerInterrupt, fill = T)

#####################################################################################################

# a