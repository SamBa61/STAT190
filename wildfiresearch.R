rm(list = ls())

library(maps)
library(mapdata)
library(ggplot2)
library(dplyr)


bigwild <- read.csv("bigdata.csv", stringsAsFactors = FALSE)





#####################subsetting/cleaning data##################

subset_data <- subset(bigwild, select = c('OBJECTID', 'FIRE_NAME', 'FIRE_YEAR', 
    'DISCOVERY_DATE', 'NWCG_CAUSE_CLASSIFICATION', 'NWCG_GENERAL_CAUSE', 'CONT_DATE', 
    'FIRE_SIZE', 'FIRE_SIZE_CLASS', 'LATITUDE', 'LONGITUDE', 'STATE', 'COUNTY', 
    'FIPS_CODE', 'FIPS_NAME'))

onlybigwildfires <- subset_data[subset_data$FIRE_SIZE > 50, ]
#onlybigwildfires <- subset_data[subset_data$FIRE_SIZE_CLASS %in% c("E", "F", "G"),]						


# Convert the CONT_DATE & DISCOVERY_DATE column to Date format
onlybigwildfires$CONT_DATE <- as.Date(onlybigwildfires$CONT_DATE, format = "%m/%d/%Y")
onlybigwildfires$DISCOVERY_DATE <- as.Date(onlybigwildfires$DISCOVERY_DATE, format = "%m/%d/%Y")

# Create a subset where STATE is "CA" and date is between 2015 and 2019
wild <- onlybigwildfires %>%
  filter(STATE == "CA" & CONT_DATE >= as.Date("2015-01-01") & CONT_DATE <= as.Date("2019-12-31"))

summary(wild)

###################################


########### Helpful tables #############
table(wild$NWCG_CAUSE_CLASSIFICATION)

table(wild$NWCG_GENERAL_CAUSE)

#######################################









####################   MAPS  ###################

# Get the map data for California
california_map <- map_data("state", region = "california")


# Plot the map of California

ggplot() +
  geom_polygon(data = california_map, aes(x = long, y = lat, group = group), 
               fill = "lightblue", color = "black") +
  coord_fixed(1.3) +  # Aspect ratio adjustment
  theme_void() +      # Remove axis and gridlines
  theme(legend.position = "none") + # Remove legend
  labs(title = "Map of California with Wildfire Data") +
  
  # Add points to the map based on latitude and longitude from the 'wild' dataset
  geom_point(data = wild, aes(x = LONGITUDE, y = LATITUDE), 
             color = "red", size = 1)


#BY COUNTY

# Get the map data for California counties
california_county_map <- map_data("county", region = "california")


# Plot the map of California with county lines
ggplot() +
  geom_polygon(data = california_county_map, aes(x = long, y = lat, group = group), 
               fill = "lightblue", color = "black") + # Add county lines
  
  # Add points to the map based on latitude and longitude from the 'wild' dataset
  geom_point(data = wild, aes(x = LONGITUDE, y = LATITUDE), 
             color = "red", size = 1) +
  
  coord_fixed(1.3) +  # Aspect ratio adjustment
  theme_void() +      # Remove axis and gridlines
  theme(legend.position = "none") + # Remove legend
  labs(title = "Map of California with Wildfire Data")

#####################################################################




#this is just picking a random section of the state we can change this to anything

# Filter latitude for Central California
wild_subset <- wild %>%
  filter(LATITUDE >= 35 & LATITUDE <= 38)

#read in weather predictor variables

fresweather <- read.csv("FresnoWeather.csv", stringsAsFactors = FALSE)

#rename columns
colnames(fresweather) <- c("date", "max_temp", "min_temp", "feelslike_max", "feelslike_min",
                           "precp_sum", "rain_sum", "wind_speed", "wind_gusts")


fresweather$date <- as.Date(fresweather$date, format = "%m/%d/%Y")



###################Creat a Y column##############################

# Create a vector of dates where fires were discovered
fire_dates <- wild_subset$DISCOVERY_DATE

# Create a column 'fire_true' in fresweather initialized with 0s
fresweather$fire_true <- 0

# Check if each date in 'fresweather' is in 'fire_dates' and assign 1 if true
fresweather$fire_true[fresweather$date %in% fire_dates] <- 1

#################################################################






###########check how many 1's in fire_true####################

# Count the number of 1s in the 'fire_true' column
num_fires <- sum(fresweather$fire_true == 1)

# Print the result
print(num_fires)

#find date duplicates
num_duplicates <- sum(duplicated(wild_subset$DISCOVERY_DATE))

# Print the result
print(num_duplicates)
###############################################################


# Create the linear regression model
m1 <- glm(fire_true ~ max_temp + min_temp + feelslike_max + feelslike_min +
           precp_sum + rain_sum + wind_speed + wind_gusts, data = fresweather,
         family = binomial(link = "logit"))

summary(m1)

m2 <- lm(fire_true ~ max_temp + min_temp + feelslike_max + feelslike_min +
            precp_sum + rain_sum + wind_speed + wind_gusts, data = fresweather)

summary(m2)


























######Fresno county drought data

#drought <- read.csv("fresno-county-drought.csv", stringsAsFactors = FALSE)

# Subset the dataset 
#drought <- drought[, c("None", "D0", "D1", "D2", "D3", "D4", 
                       "ValidStart", "ValidEnd")]

#drought$ValidStart <- as.Date(drought$ValidStart, format = "%m/%d/%Y")
#drought$ValidEnd <- as.Date(drought$ValidEnd, format = "%m/%d/%Y")


# Create a sequence of dates from January 1, 2015, to December 31, 2019
#all_dates <- seq(as.Date("2015-01-01"), as.Date("2019-12-31"), by = "day")

# Expand the 'drought' dataset to include each day within 'ValidStart' and 'ValidEnd'
#expanded_drought <- drought %>%
  #rowwise() %>%
  #mutate(Date = list(seq(ValidStart, ValidEnd, by = "day"))) %>%
  #unnest(Date)

# Ensure that the expanded dataset includes all dates
#expanded_drought <- expanded_drought %>%
  #filter(Date %in% all_dates)

#merged_data <- merge(fresweather, expanded_drought, by.x = "date", by.y = "Date", all.x = TRUE)

