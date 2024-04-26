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
library(lubridate)
library(tidyverse)



####### READING IN ALL THE WILDFIRE DATA ##########################

all_wild_data <- read.csv("bigdata.csv", stringsAsFactors = FALSE)

##################### Sub-setting/Cleaning all_wild_data ##################


#taking helping columns and getting rid of a lot here 
wild_good_columns <- subset(all_wild_data, select = c('OBJECTID', 'FIRE_NAME', 'FIRE_YEAR', 
    'DISCOVERY_DATE', 'NWCG_CAUSE_CLASSIFICATION', 'NWCG_GENERAL_CAUSE', 'CONT_DATE', 
    'FIRE_SIZE', 'FIRE_SIZE_CLASS', 'LATITUDE', 'LONGITUDE', 'STATE', 'COUNTY', 
    'FIPS_CODE', 'FIPS_NAME'))


#subset to only wild fires 20 acres or more (this was a subjective choice on size)
onlybigwildfires <- wild_good_columns[wild_good_columns$FIRE_SIZE > 20, ]


# Convert the CONT_DATE & DISCOVERY_DATE column to Date format
onlybigwildfires$CONT_DATE <- as.Date(onlybigwildfires$CONT_DATE, format = "%m/%d/%Y")
onlybigwildfires$DISCOVERY_DATE <- as.Date(onlybigwildfires$DISCOVERY_DATE, format = "%m/%d/%Y")


# Create a subset where STATE is "CA" and date is between July 2015 and 2020
# Picked this date range because of power grid data set only went through 2020-12-31
all_CA_wild <- onlybigwildfires %>%
  filter(STATE == "CA" & CONT_DATE >= as.Date("2015-07-01") & CONT_DATE <= as.Date("2020-12-31"))


#####################################################################






################# SUBSETTING/CLEAING CITY WEATHER DATA ###################


# REASONING FOR 5 CITIES- When thinking about weather data and trying to 
      # characterize the region we thought picking 5 points (4 corners, and the middle)
      # would give us a good representation of the weather of a region

# NOTE: We split California into 5 regions which is a pretty big area but the idea is that
      # You can make these regions as big or as small as is relevant for MidAmerican just
      # by picking 5 points (doesn't have to be a city) and getting the latitude and longitude



# OUR CITIES-
# Oakland - top left, Benton - top right, Carmel Valley - bottom left, 
# Scranton - bottom right, Fresno - middle

#read in weather predictor variables for CISO (central California) region
#choose 5 relevant cities in the region to generalize the weather

c1weather <- read.csv("Oakland.csv", stringsAsFactors = FALSE)
c2weather <- read.csv("Benton.csv", stringsAsFactors = FALSE)
c3weather <- read.csv("Carmel Valley.csv", stringsAsFactors = FALSE)
c4weather <- read.csv("Scranton.csv", stringsAsFactors = FALSE)
c5weather <- read.csv("Fresno.csv", stringsAsFactors = FALSE)

# Extract the first value from the "latitude" and "longitude" column for later
c1_latitude <- as.numeric(c1weather$latitude[1]) 
c1_longitude <- as.numeric(c1weather$longitude[1]) 
c2_latitude <- as.numeric(c2weather$latitude[1])
c2_longitude <- as.numeric(c2weather$longitude[1])
c3_latitude <- as.numeric(c3weather$latitude[1]) 
c3_longitude <- as.numeric(c3weather$longitude[1])
c4_latitude <- as.numeric(c4weather$latitude[1]) 
c4_longitude <- as.numeric(c4weather$longitude[1])
c5_latitude <- as.numeric(c5weather$latitude[1]) 
c5_longitude <- as.numeric(c5weather$longitude[1])


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

Weather <- c1weather %>%
  merge( c2weather, by="date") %>%
  merge( c3weather, by="date") %>%
  merge( c4weather, by="date") %>%
  merge( c5weather, by="date") 
  
Weather <- subset(Weather, select = -c(c1_date, c2_date, c3_date, c4_date, c5_date))

# Convert all columns to numeric
Weather[, -1] <- lapply(Weather[, -1], as.numeric)




############### Create new columns that we think might be meaningful ######################

# LOTS of things you can in make new columns these are just a few that I thought might be
# helpful at predicting wildfires


# Calculate mean, max, and min temperatures over the five cities for each day
Weather$mean_temp <- rowMeans(Weather[, grepl("_mean_temp", names(Weather))], na.rm = TRUE)
Weather$max_temp <- apply(Weather[, grepl("_max_temp", names(Weather))], 1, max, na.rm = TRUE)
Weather$min_temp <- apply(Weather[, grepl("_min_temp", names(Weather))], 1, min, na.rm = TRUE)

# Calculate average wind speed and gusts over the five cities for each day
Weather$avg_wind_speed <- rowMeans(Weather[, grepl("_wind_speed", names(Weather))], na.rm = TRUE)
Weather$avg_wind_gusts <- rowMeans(Weather[, grepl("_wind_gusts", names(Weather))], na.rm = TRUE)

# Calculate total rainfall over different time periods
Weather$total_rain_last_month <- rowSums(Weather[, grepl("_rain_sum", names(Weather))], na.rm = TRUE)



################ Create CISO_wild (Central California) ###################

#CISO_wild - gathers all of the wildfires that happened in the CISO region


# Filter latitude for Central California
#THESE NUMBERS ARE BASED ON OUR CURRENT 5 CITIES
CISO_wild <- all_CA_wild %>%
  filter(LATITUDE >= 36.4 & LATITUDE <= 37.8)





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




############### RANDOM FOREST!#########################

#DATA Prep

Weather$fire_true <- factor(Weather$fire_true, levels = c(0, 1), labels = c("No", "Yes"))

# RNGkind(sample.kind = "default")
# set.seed(2291352)
# train.idx <- sample(x = 1:nrow(Weather), size = floor(.8*nrow(Weather)))
# train.df <- Weather[train.idx, ]
# test.df <- Weather[-train.idx, ]

train.df <- subset(Weather, date <= "2019-12-31")
test.df <- subset(Weather, date > "2019-12-31")

# Remove the "date" column
train.df <- train.df[, -which(names(train.df) == "date")]


#403 test 1608 train

#str(train.df)
#str(test.df)




##### BASELINE FOREST #############

#Just to see how long it will take to run 1

#myforest <- randomForest(fire_true ~ .,
 #                        data = train.df,
  #                       ntree = 1000, #fit B = 1000 trees
   #                      mtry = 4, #randomly sample 4 x's at each tree
    #                     importance = TRUE) #helps identitify important predictors
#myforest
######################################


################## LOOPING THROUGH MTRY AND FOREST ###############

mtry <- c(1:12) #CAN CHANGE 
n_reps <- 10 # how many times do you want to fit each forest? for averaging

#make room for m, OOB error
keeps2 <- data.frame(m = rep(NA,length(mtry)*n_reps),
                     OOB_err_rate = rep(NA, length(mtry)*n_reps))

j = 0 #initialize row to fill
for (rep in 1:n_reps){
  print(paste0("Repetition = ", rep))
  for (idx in 1:length(mtry)){
    j = j + 1 #increment row to fill over double loop
    tempforest<- randomForest(fire_true ~ .,
                              data = train.df, 
                              ntree = 1000, #fix B at 1000!
                              mtry = mtry[idx]) #mtry is varying
    
    #record iteration's m value in j'th row
    keeps2[j , "m"] <- mtry[idx]
    #record oob error in j'th row
    keeps2[j ,"OOB_err_rate"] <- mean(predict(tempforest)!= train.df$fire_true)
  }
}
keeps2






#calculate mean for each m value
keeps3 <- keeps2 %>% 
  group_by(m) %>% 
  summarise(mean_oob = mean(OOB_err_rate))


#plot you can use to justify your chosen tuning parameters
ggplot(data = keeps3) +
  geom_line(aes(x=m, y=mean_oob)) + 
  theme_bw() + labs(x = "m (mtry) value", y = "OOB error rate") +
  scale_x_continuous(breaks = c(1:12))


############################################################





#fit final forest (mtry 2 was the best as we saw in the plot)
final_forest <- randomForest(fire_true ~ .,
                             data = train.df,
                             ntree = 1000, #fit B = 1000 trees
                             mtry = 2, #randomly sample 2 x's at each tree
                             importance = TRUE) #helps identitify important predictors
final_forest


########### INTERPRET ####################

varImpPlot(final_forest, type = 1)



#################### RocCurve #####################


pi_hat <- predict(final_forest, test.df, type = "prob")[,"Yes"] #note positive event

rocCurve <- roc(response = test.df$fire_true,
                predictor = pi_hat,
                levels = c("No", "Yes")) #negative, then positive

#ROC CURVE PLOT with ggPlot
data.frame(sensitivities = rocCurve$sensitivities,
           specificities = rocCurve$specificities)%>%
  arrange(sensitivities) %>%
ggplot() + 
  geom_line(aes(x = 1-specificities, y =sensitivities )) +
  geom_label(aes(x = .25, y = .9, label = ".170 (0.757, 0.917")) +
  theme_bw() +
  labs(x = "False Positive Rate", y = "True Positive Rate")




pi_star <- coords(rocCurve, "best", ret = "threshold")$threshold[1]
pi_star

test.df$forest_pred <- ifelse(pi_hat > pi_star, "Yes", "No")

test.df$forest_pred_prob <- predict(final_forest, test.df, type = "prob")[,2]

Weather$forest_pred_prob <- predict(final_forest, Weather, type = "prob")[,2]


# Plot with date as x axis, forest_pred_prob as contionus line
# assumption that the weather was the same

ggplot(test.df, aes(x = date, y = forest_pred_prob)) +
  geom_line() +  # Continuous line for forest_pred_prob
  geom_point(data = subset(test.df, forest_pred == "Yes"), color = "red") +  # Dots where forest_pred == "Yes"
  labs(x = "Date", y = "Forest Prediction Probability") +  # Labels for axes
  theme_minimal()  # Minimalist theme




pred_dates <- subset(test.df, forest_pred == "Yes")$date

ggplot(test.df, aes(x = date, y = forest_pred_prob)) +
  geom_line() +  # Continuous line for forest_pred_prob
  geom_vline(xintercept = as.numeric(as.Date(pred_dates)), color = "grey", alpha = 0.6) +  # Grey vertical lines
  labs(
    title = "Predictions for 2021",  # Add title
    x = "Month",  # Update x-axis label
    y = "Forest Prediction Probability"  # Y-axis label
  ) +
  scale_x_date(date_breaks = "1 month", date_labels = "%b") +  # Show only the month in short form
  theme_minimal()  # Minimalist theme







############################# Time Series GGPlots ####################################

pi_hat <- predict(final_forest, Weather, type = "prob")[,"Yes"] #note positive event

Weather$forest_pred <- ifelse(pi_hat > pi_star, "Yes", "No")


fire_dates <- Weather$date[Weather$fire_true == "Yes"]
pred_dates <- Weather$date[Weather$forest_pred == "Yes"]



ggplot() +
  geom_line( aes(x = date, y = c3_feelslike_max), data = Weather) +
  geom_point(aes(x = date, y = c3_feelslike_max), color = "red", data = subset(Weather, fire_true == "Yes")) +
  geom_vline(xintercept = as.numeric(as.Date(pred_dates)), color = "grey", alpha = 0.4) +
  labs(title = "Time Series of c3_feelslike_max with Predictions",
       x = "Date", y = "c3_feelslike_max") +
  theme_minimal()




#################### HELPFUL MAPS ###################

california_map <- map_data("state", region = "california") # Get the map data for California

# Get the map data for California counties
california_counties <- map_data("county", region = "california")

# Plot the map of California with county lines
ggplot() +
  geom_polygon(data = california_map, aes(x = long, y = lat, group = group), 
               fill = "lightblue", color = "black") +
  geom_polygon(data = california_counties, aes(x = long, y = lat, group = group), 
               fill = NA, color = "black", alpha = 0.3) +  # Add county lines
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

# Get the map data for California counties
california_counties <- map_data("county", region = "california")

# Filter the data to include only Merced County
merced_county <- subset(california_counties, grepl("modoc", subregion))

# Filter wildfire data to include only points in Merced County
merced_wild <- subset(all_CA_wild, LONGITUDE >= min(merced_county$long) & LONGITUDE <= max(merced_county$long) &
                        LATITUDE >= min(merced_county$lat) & LATITUDE <= max(merced_county$lat))

# Plot the map of California with only Merced County and red points in Merced County
ggplot() +
  geom_polygon(data = california_map, aes(x = long, y = lat, group = group), 
               fill = "lightblue", color = "black") +
  geom_polygon(data = merced_county, aes(x = long, y = lat, group = group), 
               fill = NA, color = "black", alpha = 0.7) +  # Add Merced County
  geom_point(data = merced_wild, aes(x = LONGITUDE, y = LATITUDE), 
             color = "red", size = 1) +  # Add red points in Merced County
  coord_fixed(1.3) +  # Aspect ratio adjustment
  theme_void() +      # Remove axis and gridlines
  theme(legend.position = "none") + # Remove legend
  labs(title = "Modoc County in California Wildfire Data") 




########### Helpful tables #############
max(onlybigwildfires$DISCOVERY_DATE)

table(onlybigwildfires$STATE)

table(all_CA_wild$NWCG_CAUSE_CLASSIFICATION)

table(all_CA_wild$NWCG_GENERAL_CAUSE)


#######################################


#################### Meaningful Visuals ###################################


ggplot(Weather, aes(x = total_rain_last_month, y = c3_rain_sum, color = fire_true)) +
  geom_point() +
  labs(x = "total_rain_last_month", y = "c3_rain_sum", color = "Fire True") +
  scale_color_manual(values = c("Yes" = "black", "No" = "red")) +
  theme_minimal()



