# run the demand data pull

source("/Users/sambasala/Desktop/STAT 190/DataCapstone/src/demand_pull_raw.R")

##################################################################################################################

# load in libraries

library(lubridate) # for parsing and manipulating dates in an easier way

##################################################################################################################

# remove columns unimportant to our project

demand_clean <- subset(demand_all_data, select = -c(3:6, 11:42))

##################################################################################################################

# rename columns for better conventions

colnames(demand_clean) <- c("Balancing_Authority", "Date", "Demand_MW", "Net_Generation_MW",
                                     "Total_Interchange_MW", "Valid_DIBA_MW")

##################################################################################################################

# check field data types to ensure they all work for future modeling

# str(demand_clean)

# Date is a character -> make it date
# Balancing_Authority is a character -> make it a factor

##################################################################################################################

# Changing data types

# changing Date to date data type using formatting
demand_clean$Date <- as.Date(demand_clean$Date, format = "%m/%d/%Y")

# changing Balance_Authority to a factor
demand_clean$Balancing_Authority <- as.factor(demand_clean$Balancing_Authority)

##################################################################################################################

# Aggregation and removing NAs

# Aggregate by Balancing Authorities and Date and remove NAs using na.rm
demand_clean <- aggregate(cbind(Demand_MW, Net_Generation_MW, Total_Interchange_MW, Valid_DIBA_MW) ~ Balancing_Authority + Date, 
                              data = demand_clean, 
                              FUN = sum,
                              na.rm = TRUE)

##################################################################################################################

# Creating other helpful columns

# create Year, Month, and Weekday columns for easier use when graphing and modeling
demand_clean$Year <- as.numeric(format(demand_clean$Date, "%Y"))
demand_clean$Month <- as.factor(format(demand_clean$Date, "%m"))
demand_clean$Weekday <- as.factor(weekdays(demand_clean$Date))

##################################################################################################################

# Create separate data frames for each region

# pull different balancing authorities into list
balancing_authority_list <- c("BANC", "CISO", "LDWP", "IID", "TIDC")

# empty demand_balancing_authority list
demand_balancing_authority <- list()

# for loop to iterate through list and create subset for each balancing authority
for (balancing_authority in balancing_authority_list) {
  subset_data <- subset(demand_clean, Balancing_Authority == balancing_authority)
  demand_balancing_authority[[balancing_authority]] <- subset_data
}

##################################################################################################################

# the BANC balancing authority has dates with demand values that are very unusual/extreme
# we chose to remove the range of dates containing these demand values to improve our model later
# it's understood that these demand values rarely occur
demand_balancing_authority[["BANC"]] <- subset(demand_balancing_authority[["BANC"]], !(demand_balancing_authority[["BANC"]]$Date >= as.Date("2019-04-07") & demand_balancing_authority[["BANC"]]$Date <= as.Date("2019-05-21")))
demand_balancing_authority[["BANC"]] <- subset(demand_balancing_authority[["BANC"]], !(demand_balancing_authority[["BANC"]]$Date == as.Date("2019-07-24")))