source("/Users/sambasala/Desktop/STAT 190/DataCapstone/src/demand_clean.R")

library(ggplot2)

# change dataframe to time series
demand_banc_ts <- ts(demand_banc_clean$Demand_MW, 
                     start = min(as.integer(format(as.Date(demand_banc_clean$Date), "%Y"))), 
                     end = max(as.integer(format(as.Date(demand_banc_clean$Date), "%Y"))),
                     frequency = 12)

# plots
plot(demand_banc_ts, type = "l", main = "BANC Demand Over Time", ylab = "Demand (MW)", xlab = "Year")

# 

ggplot(demand_banc_clean, aes(x = Date, y = Demand_MW)) +
  geom_line(color = "blue") +
  labs(x = "Year", y = "Demand (MW)", title = "Time Series by Year and Month")

ggplot(demand_tidc_clean, aes(x = Date, y = Demand_MW)) +
  geom_line(color = "blue") +
  labs(x = "Year", y = "Demand (MW)", title = "Time Series by Year and Month")

ggplot(demand_ciso_clean, aes(x = Date, y = Demand_MW)) +
  geom_line(color = "blue") +
  labs(x = "Year", y = "Demand (MW)", title = "Time Series by Year and Month")

ggplot(demand_ldwp_clean, aes(x = Date, y = Demand_MW)) +
  geom_line(color = "blue") +
  labs(x = "Year", y = "Demand (MW)", title = "Time Series by Year and Month")

ggplot(demand_iid_clean, aes(x = Date, y = Demand_MW)) +
  geom_line(color = "blue") +
  labs(x = "Year", y = "Demand (MW)", title = "Time Series by Year and Month")

# make normal linear model using lm(), use months as categorial and years as numeric

# create low, medium, high demand groups

# look into winsorization or imputeTS

# dlm models: local level, local linear trend, seasonal
