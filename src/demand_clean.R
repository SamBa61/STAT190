source("/Users/sambasala/Desktop/STAT 190/DataCapstone/src/demad_pull_raw.R")

str(demand_all_data)

# need to include DIBA!
demand_all_data_final <- subset(demand_all_data, select = -c(3:6, 11:16, 18:42))

colnames(demand_all_data_final) <- c("Date", "Demand_MW", "Net_Generation_MW",
                                     "Total_Interchange_MW", "Region")

str(demand_all_data_final)
# Data Date is a character -> make it date
# Region is a character -> make it a factor

demand_all_data_final$Date <- as.Date(demand_all_data_final$Date, format = "%m/%d/%Y")
demand_all_data_final$Region <- as.factor(demand_all_data_final$Region)


summary(demand_all_data_final)
# Demand has 454798 NAs
# Net Generation has 20285 NAs
# Total Interchange has 20751 NAs

# (1) remove those rows or (2) impute these values with 'typical' values 

# Handle NAs (remove) and Aggregate by Region and Date
aggregate_demand <- aggregate(cbind(Demand_MW, Net_Generation_MW, Total_Interchange_MW) ~ Region + Date, 
                              data = demand_all_data_final, 
                              FUN = sum,
                              na.rm = TRUE)

str(aggregate_demand)
summary(aggregate_demand)

unique(aggregate_demand$Region)
