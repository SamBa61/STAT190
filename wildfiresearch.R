rm(list = ls())

library(maps)
library(mapdata)
library(ggplot2)
library(dplyr)




wild <- read.csv("bigdata.csv", stringsAsFactors = FALSE)


#subsetting data##################
subset_data <- subset(wild, select = c('OBJECTID', 'FIRE_NAME', 'FIRE_YEAR', 
    'DISCOVERY_DATE', 'NWCG_CAUSE_CLASSIFICATION', 
    'NWCG_GENERAL_CAUSE', 'CONT_DATE', 'FIRE_SIZE', 'FIRE_SIZE_CLASS', 'LATITUDE', 
    'LONGITUDE', 'STATE', 'COUNTY', 'FIPS_CODE', 'FIPS_NAME'))

wild <- subset_data[subset_data$FIRE_SIZE_CLASS %in% c("E", "F", "G"),]						

summary(smallwildfires)

###################################
summary(wild)


sort(table(wild$STATE), decreasing = TRUE)
table(wild$COUNTY[wild$STATE == "CA"])
table(wild$STATE == "CA")

#INTERSETING SUBSETS########################

# Convert the CONT_DATE column to Date format
wild$CONT_DATE <- as.Date(wild$CONT_DATE, format = "%m/%d/%Y")

# Create a subset where STATE is "CA" and date is between 2015 and 2019
subset_ca_dates <- wild %>%
  filter(STATE == "CA" & CONT_DATE >= as.Date("2015-01-01") & CONT_DATE <= as.Date("2019-12-31"))

# Display the subset
print(subset_ca_dates)

summary(subset_ca_dates)

#########################################################



# Get the map data for California and Idaho
california_map <- map_data("state", region = "california")



# Subset the data to include only rows where STATE is "CA" or "ID"
wild_ca <- subset(wild, STATE == "CA")



# Plot the map of California
ggplot() +
  geom_polygon(data = california_map, aes(x = long, y = lat, group = group), 
               fill = "lightblue", color = "black") +
  coord_fixed(1.3) +  # Aspect ratio adjustment
  theme_void() +      # Remove axis and gridlines
  theme(legend.position = "none") + # Remove legend
  labs(title = "Map of California with Wildfire Data") +
  
  # Add points to the map based on latitude and longitude from the 'wild' dataset
  geom_point(data = wild_ca, aes(x = LONGITUDE, y = LATITUDE), 
             color = "red", size = 1)



ggplot() +
  geom_polygon(data = idaho_map, aes(x = long, y = lat, group = group), 
               fill = "lightblue", color = "black") +
  coord_fixed(1.3) +  # Aspect ratio adjustment
  theme_void() +      # Remove axis and gridlines
  theme(legend.position = "none") + # Remove legend
  labs(title = "Map of Idaho with Wildfire Data") +
  
  # Add points to the map based on latitude and longitude from the 'wild' dataset
  geom_point(data = wild_id, aes(x = LONGITUDE, y = LATITUDE), 
             color = "red", size = 1)




#############BY COUNTY###############################



# Get the map data for California counties
california_county_map <- map_data("county", region = "california")


# Plot the map of California with county lines
ggplot() +
  geom_polygon(data = california_county_map, aes(x = long, y = lat, group = group), 
               fill = "lightblue", color = "black") + # Add county lines
  
  # Add points to the map based on latitude and longitude from the 'wild_ca' dataset
  geom_point(data = wild_ca, aes(x = LONGITUDE, y = LATITUDE), 
             color = "red", size = 1) +
  
  coord_fixed(1.3) +  # Aspect ratio adjustment
  theme_void() +      # Remove axis and gridlines
  theme(legend.position = "none") + # Remove legend
  labs(title = "Map of California with Wildfire Data")
