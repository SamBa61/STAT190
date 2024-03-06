source("/Users/sambasala/Desktop/STAT 190/DataCapstone/src/demand_pull_raw.R")

# get rid of unecessary columns
demand_clean <- subset(demand_all_data, select = -c(3:6, 11:16, 18:42))

colnames(demand_clean) <- c("Balancing_Authority", "Date", "Demand_MW", "Net_Generation_MW",
                                     "Total_Interchange_MW", "Valid_DIBA_MW", "Region")

# create subset for CAL region
demand_clean <- subset(demand_clean, Region == "CAL")

# remove region from demand_clean
demand_clean <- subset(demand_clean, select = -c(7))

# check data types
str(demand_clean)
# Date is a character -> make it date
# Balancing_Authority is a character -> make it a factor

demand_clean$Date <- as.Date(demand_clean$Date, format = "%m/%d/%Y")
demand_clean$Balancing_Authority <- as.factor(demand_clean$Balancing_Authority)
str(demand_clean)

summary(demand_clean)
# Demand has 1647 NAs
# Net Generation has 1645 NAs
# Total Interchange has 1799 NAs
# Valid_DIBA_MW has 13621 NAs
# deal with these by using na.rm in aggregation

# Aggregate by Balancing Authorities in California and Date
demand_clean <- aggregate(cbind(Demand_MW, Net_Generation_MW, Total_Interchange_MW, Valid_DIBA_MW) ~ Balancing_Authority + Date, 
                              data = demand_clean, 
                              FUN = sum,
                              na.rm = TRUE)

str(demand_clean)
summary(demand_clean)

# create low, medium, high demand Factor column
# will need to dig back into STAT 172 notes to do this





