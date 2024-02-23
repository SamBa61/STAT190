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



#separate town
Final_CustServiceInterrupt <- Final_CustServiceInterrupt %>%
  separate(Infrastructure_Name, into = c("Town", "System"), sep = ": ", extra = "merge")

# Remove column Megawatts_Interrupted
Final_CustServiceInterrupt <- Final_CustServiceInterrupt[, -which(names(Final_CustServiceInterrupt) == "Megawatts_Interrupted")]


# Filter out rows where Duration_min is "still out"
Final_CustServiceInterrupt <- Final_CustServiceInterrupt %>%
  filter(Duration_min != "still out")

# Convert Duration_min to numeric
Final_CustServiceInterrupt$Duration_min <- as.numeric(Final_CustServiceInterrupt$Duration_min)


summary(Final_CustServiceInterrupt)


#if you wanted a smaller graph take out low obersvation counts
#Final_CustServiceInterrupt <- Final_CustServiceInterrupt %>%
  #filter(Field_Cause != "Environmental")




####VISUALIZATIONS############

#count of outages in each district
table(Final_CustServiceInterrupt$Operations_Management_District)

#how many of each voltage
ggplot(data = Final_CustServiceInterrupt) +
  geom_histogram(aes(x = Voltage_kV))


#Looking at Field Cause within certain districts TOP 4 districts by observations

ggplot(data = Final_CustServiceInterrupt[Final_CustServiceInterrupt$Operations_Management_District=="SPK", ]) +
  geom_bar(aes(x = Field_Cause)) +
  geom_text(aes(x = Field_Cause, y = ..count.., label = ..count..), stat = "count", size = 3, vjust = -0.5) +
  ggtitle("District SPK") +
  coord_flip()

ggplot(data = Final_CustServiceInterrupt[Final_CustServiceInterrupt$Operations_Management_District=="TRI", ]) +
  geom_bar(aes(x = Field_Cause)) +
  geom_text(aes(x = Field_Cause, y = ..count.., label = ..count..), stat = "count", size = 3, vjust = -0.5) +
  ggtitle("District TRI") +
  coord_flip()

ggplot(data = Final_CustServiceInterrupt[Final_CustServiceInterrupt$Operations_Management_District=="EUG", ]) +
  geom_bar(aes(x = Field_Cause)) +
  geom_text(aes(x = Field_Cause, y = ..count.., label = ..count..), stat = "count", size = 3, vjust = -0.5) +
  ggtitle("District EUG") +
  coord_flip()
  
ggplot(data = Final_CustServiceInterrupt[Final_CustServiceInterrupt$Operations_Management_District=="KAL", ]) +
  geom_bar(aes(x = Field_Cause)) +
  geom_text(aes(x = Field_Cause, y = ..count.., label = ..count..), stat = "count", size = 3, vjust = -0.5) +
  ggtitle("District KAL") +
  coord_flip()





#VERY UNHELPFUL TRYING TO FIND DURATION_MIN FOR FIELD CAUSE---------------------------------------

# Filter data for District SPK
SPK_data <- Final_CustServiceInterrupt[Final_CustServiceInterrupt$Operations_Management_District == "SPK", ]

# Summarize the data
summarized_data <- SPK_data %>%
  group_by(Field_Cause) %>%
  summarize(total_duration = mean(Duration_min)) %>% #can change to sum() but mean tells a better story
  top_n(25, total_duration)  # Keep only the top 5 Field_Cause categories

# Plot the summarized data
ggplot(data = summarized_data) +
  geom_bar(aes(x = Field_Cause, y = total_duration), stat = "identity") +
  geom_text(aes(x = Field_Cause, y = total_duration, label = total_duration), size = 3, vjust = -0.5) +
  ggtitle("Top 5 Field Causes by Duration in District SPK") +
  coord_flip()
  
########################################################################




