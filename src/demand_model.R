source("/Users/sambasala/Desktop/STAT 190/DataCapstone/src/demand_clean.R")

# libraries 

library(ggplot2)
library(imputeTS)

library(dlm)
library(forecast)

# plots 

ggplot(demand_banc_clean, aes(x = Date, y = Demand_MW)) +
  geom_line(color = "blue") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") + 
  labs(x = "Year", y = "Demand (MW)", title = "Demand Time Series by Year") +
  theme_bw()

ggplot(demand_tidc_clean, aes(x = Date, y = Demand_MW)) +
  geom_line(color = "blue") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") + 
  labs(x = "Year", y = "Demand (MW)", title = "Demand Time Series by Year") +
  theme_bw()

ggplot(demand_ciso_clean, aes(x = Date, y = Demand_MW)) +
  geom_line(color = "blue") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") + 
  labs(x = "Year", y = "Demand (MW)", title = "Demand Time Series by Year") +
  theme_bw()

ggplot(demand_ldwp_clean, aes(x = Date, y = Demand_MW)) +
  geom_line(color = "blue") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") + 
  labs(x = "Year", y = "Demand (MW)", title = "Demand Time Series by Year") +
  theme_bw()

ggplot(demand_iid_clean, aes(x = Date, y = Demand_MW)) +
  geom_line(color = "blue") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") + 
  labs(x = "Year", y = "Demand (MW)", title = "Demand Time Series by Year") +
  theme_bw()

# Modeling

# linear regression model using lm()
# use months as categorical, weekday as categorical, and years as numeric

m1 = lm(data = demand_banc_clean, Demand_MW ~ Month + Year + Weekday)
summary(m1)

demand_banc_clean$preds <- predict(m1)

ggplot(demand_banc_clean) +
  geom_line(aes(x = Date, y = Demand_MW), color = "blue") +
  geom_line(aes(x = Date, y = preds), color = "red") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") + 
  labs(x = "Year", y = "Demand (MW)", title = "Demand Time Series by Year") +
  theme_bw()

m2 = lm(data = demand_ciso_clean, Demand_MW ~ Month + Year + Weekday)
summary(m2)

demand_ciso_clean$preds <- predict(m2)

ggplot(demand_ciso_clean) +
  geom_line(aes(x = Date, y = Demand_MW), color = "blue") +
  geom_line(aes(x = Date, y = preds), color = "red") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") + 
  labs(x = "Year", y = "Demand (MW)", title = "Demand Time Series by Year") +
  theme_bw()

# Using ImputeTS package to clean up data








# MORE COMPLICATED
# dlm package models: local level, local linear trend, seasonal
# forecast package models: SARIMA model (no covariates)
# 2010 day time difference, but only 1991 observations
# there must be days of data that are missing

all_dates <- seq(as.Date("2015-07-01"), as.Date("2020-12-31"), by = "day")
dates_difference <- setdiff(all_dates, demand_banc_clean$Date)
dates_difference_as_dates <- as.Date(dates_difference, origin = "1970-01-01")
print(dates_difference_as_dates)

# how should I go about this?

demand_banc_ts <- ts(demand_banc_clean$Demand_MW, 
                     start = min(as.integer(format(as.Date(demand_banc_clean$Date), "%Y"))), 
                     end = max(as.integer(format(as.Date(demand_banc_clean$Date), "%Y"))),
                     frequency = 365)

demand_banc_ts <- ts(demand_banc_clean$Demand_MW, 
                     start = c(2015, 7), 
                     end = c(2020, 12),
                     frequency = 365)

plot(demand_banc_ts)

demand_covariates <- data.frame(demand_banc_clean$Total_Interchange_MW,
                                demand_banc_clean$Net_Generation_MW)

dim(demand_banc_ts)
dim(demand_covariates)

sarima_model_with_covariates <- Arima(demand_banc_ts, xreg = demand_covariates)

summary(sarima_model_with_covariates)

# create low, medium, high demand groups - DO THIS AFTERWORDS
demand_banc_clean$Demand_Category <- cut(data$value, 
                                         breaks = c(), 
                                         labels = c("Low", "Medium", "High"), 
                                         include.lowest = TRUE)

