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

# pull different balancing authorities into list
balancing_authority_list <- c("BANC", "TIDC", "CISO", "LDWP", "IID")

# for loop iterate through list and create model for each
# loop also creates a binary and 3-type categorical demand columns
for (balancing_authority in balancing_authority_list) {
  subset_name <- paste0("demand_", tolower(balancing_authority))
  subset_data <- assign(subset_name, subset(demand_clean, Balancing_Authority == balancing_authority))
  subset_data$Demand_Category_Bin <- as.factor(ifelse(subset_data$Demand_MW >= median(subset_data$Demand_MW), "High", "Low"))
  subset_data$Demand_Category <- as.factor(cut(subset_data$Demand_MW, breaks = c(min(subset_data$Demand_MW), quantile(subset_data$Demand_MW, 1/3), quantile(subset_data$Demand_MW, 2/3), max(subset_data$Demand_MW)), labels = c("Low", "Medium", "High")))
  assign(subset_name, subset_data)
}

##################################################################################################################

