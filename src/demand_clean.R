source("/Users/sambasala/Desktop/STAT 190/DataCapstone/src/demand_pull_raw.R")

library(dlm) # for creating a time series models with the data
library(lubridate)

# get rid of unecessary columns
demand_clean <- subset(demand_all_data, select = -c(3:6, 11:42))

colnames(demand_clean) <- c("Balancing_Authority", "Date", "Demand_MW", "Net_Generation_MW",
                                     "Total_Interchange_MW", "Valid_DIBA_MW")

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

# create time series models for 5 balancing authorities: BANC, TIDC, CISO, LDWP, IID
demand_banc_clean <- subset(demand_clean, Balancing_Authority == "BANC")
demand_tidc_clean <- subset(demand_clean, Balancing_Authority == "TIDC")
demand_ciso_clean <- subset(demand_clean, Balancing_Authority == "CISO")
demand_ldwp_clean <- subset(demand_clean, Balancing_Authority == "LDWP")
demand_iid_clean <- subset(demand_clean, Balancing_Authority == "IID")

# change dataframe to time series
my_time_series <- ts(demand_banc_clean$Demand_MW, 
                     start = min(as.integer(format(as.Date(demand_banc_clean$Date), "%Y"))), 
                     end = max(as.integer(format(as.Date(demand_banc_clean$Date), "%Y"))),
                     frequency = 12)

plot(my_time_series, type = "l", main = "title")


# create low, medium, high demand groups




