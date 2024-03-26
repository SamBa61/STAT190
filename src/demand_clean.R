# run the demand data pull (might have to change link)

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

str(demand_clean)

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
  
# 5 California balancing authorities: BANC, TIDC, CISO, LDWP, IID
demand_banc_clean <- subset(demand_clean, Balancing_Authority == "BANC")
demand_tidc_clean <- subset(demand_clean, Balancing_Authority == "TIDC")
demand_ciso_clean <- subset(demand_clean, Balancing_Authority == "CISO")
demand_ldwp_clean <- subset(demand_clean, Balancing_Authority == "LDWP")
demand_iid_clean <- subset(demand_clean, Balancing_Authority == "IID")


