# clear workspace
rm(list = ls())

# libraries
library(rvest)
library(dplyr)
library(ggplot2)

#####################################################################################################

# loading in data from 2018-2024 (keeps things current)
# how many years back should we go?

CustServiceInterrupt <- list()
TransmissionInterrupt <- list()
TransformerInterrupt <- list()

# loop that accesses URLs and pulls HTML code
for (year in 2018:2024) {
  
  url <- paste0("https://transmission.bpa.gov/Business/Operations/Outages/OutagesCY", year, ".htm")
  outage_data <- read_html(url) %>%
    html_table()
  
  Sys.sleep(2) # delay between requests
  
  print(paste('scraping data for year: ', year))
  
  i <- length(CustServiceInterrupt) + 1
  
  # if statements that deal with differing # of tables if older data is pulled
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

# creating final data frames
Final_CustServiceInterrupt <- data.table::rbindlist(CustServiceInterrupt, fill = T)
Final_TransmissionInterrupt <- data.table::rbindlist(TransmissionInterrupt, fill = T)
Final_TransformerInterrupt <- data.table::rbindlist(TransformerInterrupt, fill = T)

# assigning column names
colnames(Final_CustServiceInterrupt) <- c("Out_Datetime", "In_Datetime", "Infrastructure_Name", "Voltage_kV", "Duration_min",
                                          "Outage_Type", "Field_Cause", "Responsible_System",
                                          "Megawatts_Interrupted", "Operations_Management_District", "OutageID")
colnames(Final_TransmissionInterrupt) <- c("Out_Datetime", "In_Datetime", "Infrastructure_Name", "Voltage_kV", "Line_Type", "Gen_Flag", "Length_miles",
                                                 "Duration_min", "Outage_Type", "Field_Cause", "Responsible_System", "Operations_Management_District",
                                                 "Transmission_Owner_NERC_TADS", "Outage_ID")
colnames(Final_TransformerInterrupt) <- c("Out_Datetime", "In_Datetime", "Infrastructure_Name", "High_Voltage_kV", "Low_Voltage_kV",
                                                "Duration_min", "Outage_Type", "Field_Cause", "Responsible_System", "Operations_Management_District",
                                                "Transmission_Owner_NERC_TADS", "Outage_ID")

#####################################################################################################

# Data Exploration - Is there a specific dataset we should focus on?

# Customer Service

str(Final_CustServiceInterrupt)
summary(Final_CustServiceInterrupt)

# Final_CustServiceInterrupt$Out_Datetime
unique(Final_CustServiceInterrupt$Out_Datetime)
# out datetimes are characters - will need to change to date using lubridate

# Final_CustServiceInterrupt$In_Datetime
unique(Final_CustServiceInterrupt$In_Datetime)
table(Final_CustServiceInterrupt$In_Datetime)
# there are 104 nulls!?
# in datetimes are characters and some are blank

# Final_CustServiceInterrupt$Infrastructure_Name
unique(Final_CustServiceInterrupt$Infrastructure_Name)
# break apart infrastructure name - town: utility company, voltage, type of feeder

# Final_CustServiceInterrupt$Voltage_kV
hist(Final_CustServiceInterrupt$Voltage_kV) 
# somewhat normal

# Final_CustServiceInterrupt$Duration_min
unique(Final_CustServiceInterrupt$Duration_min) 
table(Final_CustServiceInterrupt$Duration_min)
# duration is character because of "still out"
# there are also 0's
# look at histogram of duration (once data type is changed)

# Final_CustServiceInterrupt$Outage_Type
unique(Final_CustServiceInterrupt$Outage_Type)
table(Final_CustServiceInterrupt$Outage_Type)
# Auto Plan 
# 5047 2099 

# Final_CustServiceInterrupt$Field_Cause
unique(Final_CustServiceInterrupt$Field_Cause)
table(Final_CustServiceInterrupt$Field_Cause)
# should consider grouping these?

# Final_CustServiceInterrupt$Responsible_System
unique(Final_CustServiceInterrupt$Responsible_System)
table(Final_CustServiceInterrupt$Responsible_System)
# there is 1 null - dump into BPA?

# Final_CustServiceInterrupt$Megawatts_Interrupted
unique(Final_CustServiceInterrupt$Megawatts_Interrupted)
table(Final_CustServiceInterrupt$Megawatts_Interrupted)
# None Unknown 
# 910  5836
# megawatts interrupted is also character because of "none" and "unknown"
# look at histogram of megawatts interrupted (once data type is changed)

# Final_CustServiceInterrupt$Operations_Management_District
unique(Final_CustServiceInterrupt$Operations_Management_District)
table(Final_CustServiceInterrupt$Operations_Management_District)
# there are 2 null values to change - dump into TRI?

# can group values into ranges or deal with converting to numeric type



# Transmission Interruptions

str(Final_TransmissionInterrupt)
summary(Final_TransmissionInterrupt)

# Final_TransmissionInterrupt$Out_Datetime
unique(Final_TransmissionInterrupt$Out_Datetime)
# out datetimes are characters - will need to change to date using lubridate

# Final_TransmissionInterrupt$In_Datetime
unique(Final_TransmissionInterrupt$In_Datetime)
table(Final_TransmissionInterrupt$In_Datetime)
# there are 391 nulls!?
# in datetimes are characters and some are blank

# Final_TransmissionInterrupt$Infrastructure_Name
unique(Final_TransmissionInterrupt$Infrastructure_Name)
# break apart infrastructure name

# Final_TransmissionInterrupt$Voltage_kV
hist(Final_TransmissionInterrupt$Voltage_kV) 
# we have outliers but they could be important

# Final_TransmissionInterrupt$Line_Type
unique(Final_TransmissionInterrupt$Line_Type) 
table(Final_TransmissionInterrupt$Line_Type)

# Final_TransmissionInterrupt$Gen_Flag
unique(Final_TransmissionInterrupt$Gen_Flag) 
table(Final_TransmissionInterrupt$Gen_Flag)
# 14694 null values - what does this mean?

# Final_TransmissionInterrupt$Length_miles
unique(Final_TransmissionInterrupt$Length_miles) 
table(Final_TransmissionInterrupt$Length_miles)
# there are 0 miles and nulls

# Final_TransmissionInterrupt$Duration_min
unique(Final_TransmissionInterrupt$Duration_min) 
table(Final_TransmissionInterrupt$Duration_min)
# duration is character because of "still out"
# there are also 0's and a -10
# look at histogram of duration (once data type is changed)

# Final_TransmissionInterrupt$Outage_Type
unique(Final_TransmissionInterrupt$Outage_Type)
table(Final_TransmissionInterrupt$Outage_Type)
# Auto  Plan 
# 11965 11234 

# Final_TransmissionInterrupt$Field_Cause
unique(Final_TransmissionInterrupt$Field_Cause)
table(Final_TransmissionInterrupt$Field_Cause)
# should consider grouping these?

# Final_TransmissionInterrupt$Responsible_System
unique(Final_TransmissionInterrupt$Responsible_System)
table(Final_TransmissionInterrupt$Responsible_System)

# Final_TransmissionInterrupt$Operations_Management_District
unique(Final_TransmissionInterrupt$Operations_Management_District)
table(Final_TransmissionInterrupt$Operations_Management_District)
# there are 170 null values to change - dump into SPK?

# Final_TransmissionInterrupt$Transmission_Owner_NERC_TADS
unique(Final_TransmissionInterrupt$Transmission_Owner_NERC_TADS)
table(Final_TransmissionInterrupt$Transmission_Owner_NERC_TADS)
# there are 528 null values to change - dump into BPAT?



# Transformer Interruptions

str(Final_TransformerInterrupt)
summary(Final_TransformerInterrupt)

# Final_TransformerInterrupt$Out_Datetime
unique(Final_TransformerInterrupt$Out_Datetime)
# out datetimes are characters - will need to change to date using lubridate

# Final_TransformerInterrupt$In_Datetime
unique(Final_TransformerInterrupt$In_Datetime)
table(Final_TransformerInterrupt$In_Datetime)
# there are 18 nulls!?
# in datetimes are characters and some are blank

# Final_TransformerInterrupt$Infrastructure_Name
unique(Final_TransformerInterrupt$Infrastructure_Name)
# break apart infrastructure name - Town: kV, transformer #

# Final_TransformerInterrupt$High_Voltage_kV
hist(Final_TransformerInterrupt$High_Voltage_kV) 
# ?

# Final_TransformerInterrupt$Low_Voltage_kV
hist(Final_TransformerInterrupt$Low_Voltage_kV) 
# ?

# Final_TransformerInterrupt$Duration_min
unique(Final_TransformerInterrupt$Duration_min) 
table(Final_TransformerInterrupt$Duration_min)
# duration is character because of "still out"
# there are also 0's
# look at histogram of duration (once data type is changed)

# Final_TransformerInterrupt$Outage_Type
unique(Final_TransformerInterrupt$Outage_Type)
table(Final_TransformerInterrupt$Outage_Type)
# Auto Plan 
# 306 1032 

# Final_TransformerInterrupt$Field_Cause
unique(Final_TransformerInterrupt$Field_Cause)
table(Final_TransformerInterrupt$Field_Cause)
# should consider grouping these?

# Final_TransformerInterrupt$Responsible_System
unique(Final_TransformerInterrupt$Responsible_System)
table(Final_TransformerInterrupt$Responsible_System)

# Final_TransformerInterrupt$Operations_Management_District
unique(Final_TransformerInterrupt$Operations_Management_District)
table(Final_TransformerInterrupt$Operations_Management_District)

# Final_TransformerInterrupt$Transmission_Owner_NERC_TADS
unique(Final_TransformerInterrupt$Transmission_Owner_NERC_TADS)
table(Final_TransformerInterrupt$Transmission_Owner_NERC_TADS)
# there are 16 null values to change - dump into BPAT?

