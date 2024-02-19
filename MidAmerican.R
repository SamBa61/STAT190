# clear workspace
rm(list = ls())

# libraries
library(rvest)
library(dplyr)
library(tidyverse)
library(ggplot2)

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

colnames(Final_CustServiceInterrupt) <- c("Out_Datetime", "In_Datetime", "Infrastructure_Name", "Voltage_kV", "Duration_min",
                                          "Outage_Type", "Field_Cause", "Responsible_System",
                                          "Megawatts_Interrupted", "Operations_Management_District", "OutageID")
colnames(Final_TransmissionInterrupt) <- c("Out_Datetime", "In_Datetime", "Infrastructure_Name", "Voltage_kV", "Line_Type", "Gen_Flag", "Length_miles",
                                           "Duration_min", "Outage_Type", "Field_Cause", "Responsible_System", "Operations_Management_District",
                                           "Transmission_Owner_NERC_TADS", "Outage_ID")
colnames(Final_TransformerInterrupt) <- c("Out_Datetime", "In_Datetime", "Infrastructure_Name", "High_Voltage_kV", "Low_Voltage_kV",
                                          "Duration_min", "Outage_Type", "Field_Cause", "Responsible_System", "Operations_Management_District",
                                          "Transmission_Owner_NERC_TADS", "Outage_ID")



summary(Final_CustServiceInterrupt)

#separate town
Final_CustServiceInterrupt <- Final_CustServiceInterrupt %>%
  separate(Infrastructure_Name, into = c("Town", "System"), sep = ": ", extra = "merge")

# Remove column Megawatts_Interrupted
Final_CustServiceInterrupt <- Final_CustServiceInterrupt[, -which(names(Final_CustServiceInterrupt) == "Megawatts_Interrupted")]


ggplot(data = Final_CustServiceInterrupt) +
  geom_histogram(aes(x = Voltage_kV))


#Looking at Field Cause within certian districts

ggplot(data = Final_CustServiceInterrupt[Final_CustServiceInterrupt$Operations_Management_District=="TRI", ]) +
  geom_bar(aes(x = Field_Cause)) +
  coord_flip()

ggplot(data = Final_CustServiceInterrupt[Final_CustServiceInterrupt$Operations_Management_District=="SPK", ]) +
  geom_bar(aes(x = Field_Cause)) +
  coord_flip()

#count of outages in each district
table(Final_CustServiceInterrupt$Operations_Management_District)

