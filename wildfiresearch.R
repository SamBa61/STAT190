rm(list = ls())


#load packages
library(maps)
library(mapdata)
library(ggplot2)
library(dplyr)
library(rpart) #fitting classification trees
library(rpart.plot) #plotting classification trees
library(pROC) #for creating ROC curves
library(randomForest)



####### READING IN ALL THE WILDFIRE DATA ##########################
all_wild_data <- read.csv("bigdata.csv", stringsAsFactors = FALSE)





#####################subsetting/cleaning all_wild_data##################

wild_good_columns <- subset(all_wild_data, select = c('OBJECTID', 'FIRE_NAME', 'FIRE_YEAR', 
    'DISCOVERY_DATE', 'NWCG_CAUSE_CLASSIFICATION', 'NWCG_GENERAL_CAUSE', 'CONT_DATE', 
    'FIRE_SIZE', 'FIRE_SIZE_CLASS', 'LATITUDE', 'LONGITUDE', 'STATE', 'COUNTY', 
    'FIPS_CODE', 'FIPS_NAME'))

#subset to only wild fires 20 acres or more
onlybigwildfires <- wild_good_columns[wild_good_columns$FIRE_SIZE > 20, ]
#onlybigwildfires <- subset_data[subset_data$FIRE_SIZE_CLASS %in% c("E", "F", "G"),]						


# Convert the CONT_DATE & DISCOVERY_DATE column to Date format
onlybigwildfires$CONT_DATE <- as.Date(onlybigwildfires$CONT_DATE, format = "%m/%d/%Y")
onlybigwildfires$DISCOVERY_DATE <- as.Date(onlybigwildfires$DISCOVERY_DATE, format = "%m/%d/%Y")

# Create a subset where STATE is "CA" and date is between July 2015 and 2020
all_CA_wild <- onlybigwildfires %>%
  filter(STATE == "CA" & CONT_DATE >= as.Date("2015-07-01") & CONT_DATE <= as.Date("2020-12-31"))


###################################






################# SUBSETTING/CLEAING CITY WEATHER DATA ###################


#Oakland, Benton, Carmel Valley, Scranton, Fresno

#read in weather predictor variables for CISO region
#choose 5 relevant cities in the region to generalize the weather
c1weather <- read.csv("Oakland.csv", stringsAsFactors = FALSE)
c2weather <- read.csv("Benton.csv", stringsAsFactors = FALSE)
c3weather <- read.csv("Carmel Valley.csv", stringsAsFactors = FALSE)
c4weather <- read.csv("Scranton.csv", stringsAsFactors = FALSE)
c5weather <- read.csv("Fresno.csv", stringsAsFactors = FALSE)


c1_latitude <- c1weather$latitude[1] # Extract the first value from the "latitude" column
c1_longitude <- c1weather$longitude[1]# Extract the first value from the "longitude" column
c2_latitude <- c2weather$latitude[1]
c2_longitude <- c2weather$longitude[1]
c3_latitude <- c3weather$latitude[1] 
c3_longitude <- c3weather$longitude[1]
c4_latitude <- c4weather$latitude[1] 
c4_longitude <- c4weather$longitude[1]
c5_latitude <- c5weather$latitude[1] 
c5_longitude <- c5weather$longitude[1]


# clean weird rows
# Remove the first 3 rows using negative indexing
c1weather <- c1weather[-c(1:3), ]
c2weather <- c2weather[-c(1:3), ]
c3weather <- c3weather[-c(1:3), ]
c4weather <- c4weather[-c(1:3), ]
c5weather <- c5weather[-c(1:3), ]


# Define new column names
new_colnames <- c("date", "weather_code", "max_temp", "min_temp",  
                  "mean_temp", "feelslike_max", "feelslike_min", "feelslike_mean",
                  "daylight_time", "sunshine_time", "precp_sum", "rain_sum", 
                  "snow_sum", "precp_hrs", "wind_speed", "wind_gusts",
                  "wind_direction", "radition", "evapotranspiration")

# Assign new column names directly
colnames(c1weather) <- paste("c1", new_colnames, sep = "_")
colnames(c2weather) <- paste("c2", new_colnames, sep = "_")
colnames(c3weather) <- paste("c3", new_colnames, sep = "_")
colnames(c4weather) <- paste("c4", new_colnames, sep = "_")
colnames(c5weather) <- paste("c5", new_colnames, sep = "_")



#clean columns
c1weather$date <- as.Date(c1weather$c1_date, format = "%m/%d/%Y")
c2weather$date <- as.Date(c2weather$c2_date, format = "%m/%d/%Y")
c3weather$date <- as.Date(c3weather$c3_date, format = "%m/%d/%Y")
c4weather$date <- as.Date(c4weather$c4_date, format = "%m/%d/%Y")
c5weather$date <- as.Date(c5weather$c5_date, format = "%m/%d/%Y")




################## Combine into 1 Weather Dataset ####################

# List of datasets
datasets <- list(c1weather, c2weather, c3weather, c4weather, c5weather)

# Combine columns using cbind and do.call
Weather <- do.call(cbind, datasets)

#DATE COLUMNS ARE WEIRD





############### Create new columns ######################

#mean temp over the five cities for a certain day
#max temp over the five cities for a certain day
#min temp over the five cities for a certain day
#wind speed over the five cities for a certain day
#wind gusts over the five cities for a certain day
#rain over the last month
#rain over the last 3 months
#rain over the last year
#rain over the last 2 years

#OTHER INTERESTING COLUMNS TO ADD. SYNERGY?




################ Create CISO_wild ###################

#CISO_wild - gathers all of the wildfires that happened in the CISO region

#SAM TUCKER-
#Change the LAT/LONG to the desired regions 


#higher line
#higherSlope = (c2_longitude-c1_longitude)-(c2_latitude-c1_latitude)
#higherIntercept = c1_longitude - (m*c1_latitude)
#all_CA_wild$LONGITUDE <= higherSlope*all_CA_wild$LATITUDE + higherIntercept

#lower line
#lowerSlope = (c4_longitude-c3_longitude)-(c4_latitude-c3_latitude)
#lowerIntercept = c3_longitude - (m*c3_latitude)
#all_CA_wild$LONGITUDE > lowerSlope*all_CA_wild$LATITUDE + lowerIntercept


# Filter latitude for Central California
#THESE NUMBERS ARE BASED ON OUR CURRENT 5 CITIES
CISO_wild <- all_CA_wild %>%
  filter(LATITUDE >= 36.4 & LATITUDE <= 37.8 & LONGITUDE <= -116.4 & LONGITUDE >= -122.5)





###################Create a Y column##############################

fire_dates <- CISO_wild$DISCOVERY_DATE # Create a vector of dates where fires were discovered
Weather$fire_true <- 0 # Create a column 'fire_true' in fresweather initialized with 0s
Weather$fire_true[Weather$date %in% fire_dates] <- 1 # Check if each date in 'fresweather' is in 'fire_dates' and assign 1 if true

###########check how many 1's in fire_true####################
# Count the number of 1s in the 'fire_true' column
num_fires <- sum(Weather$fire_true == 1)
print(num_fires)
#find date duplicates
num_duplicates <- sum(duplicated(CISO_wild$DISCOVERY_DATE))
print(num_duplicates)
###############################################################







#SAM TUCKER- Create lines on this map that represent our chosen regions


#################### HELPFUL MAPS ###################

california_map <- map_data("state", region = "california") # Get the map data for California

# Plot the map of California
ggplot() +
  geom_polygon(data = california_map, aes(x = long, y = lat, group = group), 
               fill = "lightblue", color = "black") +
  coord_fixed(1.3) +  # Aspect ratio adjustment
  theme_void() +      # Remove axis and gridlines
  theme(legend.position = "none") + # Remove legend
  labs(title = "Map of California with Wildfire Data") +
  
  # Add points to the map based on latitude and longitude from the 'wild' dataset
  geom_point(data = all_CA_wild, aes(x = LONGITUDE, y = LATITUDE), 
             color = "red", size = 1)


########### ADD CISO LATITUDE LINES ##################


# Get the map data for California
california_map <- map_data("state", region = "california") 

# Plot the map of California
ggplot() +
  geom_polygon(data = california_map, aes(x = long, y = lat, group = group), 
               fill = "lightblue", color = "black") +
  
  # Add horizontal lines at LATITUDE 36.4 and 37.8
  geom_hline(yintercept = c(36.4, 37.8), linetype = "dashed", color = "black") +
  
  coord_fixed(1.3) +  # Aspect ratio adjustment
  theme_void() +      # Remove axis and gridlines
  theme(legend.position = "none") + # Remove legend
  labs(title = "Map of California with CISO_Wildfire Data") +
  
  # Add points to the map based on latitude and longitude from the 'wild' dataset
  geom_point(data = CISO_wild, aes(x = LONGITUDE, y = LATITUDE), 
             color = "red", size = 1)







########### Helpful tables #############
max(onlybigwildfires$DISCOVERY_DATE)

table(onlybigwildfires$STATE)

table(all_CA_wild$NWCG_CAUSE_CLASSIFICATION)

table(all_CA_wild$NWCG_GENERAL_CAUSE)

#######################################



#LOOK INTO RANDOM FOREST!
















####################Model work#############################

# Create the linear regression model
m1 <- glm(fire_true ~ weather_code + max_temp + min_temp + mean_temp + 
          feelslike_max + feelslike_min + feelslike_mean +
          daylight_time + sunshine_time + precp_sum + rain_sum + 
          snow_sum + precp_hrs + wind_speed + wind_gusts +
          wind_direction + radition + evapotranspiration, data = weather,
         family = binomial(link = "logit"))

summary(m1)

m2 <- lm(fire_true ~ max_temp + min_temp + feelslike_max + feelslike_min +
            precp_sum + rain_sum + wind_speed + wind_gusts, data = weather)

summary(m2)


























######Fresno county drought data

#drought <- read.csv("fresno-county-drought.csv", stringsAsFactors = FALSE)

# Subset the dataset 
#drought <- drought[, c("None", "D0", "D1", "D2", "D3", "D4", 
 #                      "ValidStart", "ValidEnd")]

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

