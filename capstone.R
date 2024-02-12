# clear workspace
rm(list = ls())

# libraries
library(rvest)
library(dplyr)

# variables and lists
start_year <- 2018
end_year <- 2024

CustServiceInterrupt <- list()
TransmissionInterrupt <- list()
TransformerInterrupt <- list()

# scraping loop
for (year in start_year:end_year) {

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
Final_TransmissionInterrupt_Final <- data.table::rbindlist(TransmissionInterrupt, fill = T)
Final_TransformerInterrupt_Final <- data.table::rbindlist(TransformerInterrupt, fill = T)

colnames(Final_CustServiceInterrupt) <- c("OutDatetime",	"InDatetime",	"Name",	"Voltage(kV)", "Duration(min)",
                                          "OutageType",	"FieldCause",	"ResponsibleSystem",
                                          "MWIntrpt",	"Operations&ManagementDistrict",	"OutageID")
colnames(Final_TransmissionInterrupt_Final) <- c("OutDatetime",	"InDatetime",	"Name",	"Voltage(kV)",	"LineType",	"GenFlag", "Length(mi)",
                                                 "Duration(min)",	"OutageType", "FieldCause",	"ResponsibleSystem", "Operations&ManagementDistrict",
                                                 "TransmissionOwnerNERCTADS",	"OutageID")
colnames(Final_TransformerInterrupt_Final) <- c("OutDatetime",	"InDatetime",	"Name",	"HighVoltage(kV)", "LowVoltage(kV)",
                                                "Duration(min)", "OutageType", "FieldCause", "ResponsibleSystem",	"Operations&ManagementDistrict",
                                                "TransmissionOwnerNERCTADS", "OutageID")



