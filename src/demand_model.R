source("/Users/sambasala/Desktop/STAT 190/DataCapstone/src/demand_clean.R")

# libraries 

library(ggplot2)
library(imputeTS)
# linear interpolation (na_interpolation)
# moving average imputation (na_ma)
# seasonal decomposition (na_seadec)

# time series plots (un-imputed)

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

demand_banc_clean$Predictions <- predict(m1)

ggplot(demand_banc_clean) +
  geom_line(aes(x = Date, y = Demand_MW), color = "blue") +
  geom_line(aes(x = Date, y = Predictions), color = "red") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") + 
  labs(x = "Year", y = "Demand (MW)", title = "Demand Time Series by Year") +
  theme_bw()

m2 = lm(data = demand_ciso_clean, Demand_MW ~ Month + Year + Weekday)
summary(m2)

demand_ciso_clean$Predictions <- predict(m2)

ggplot(demand_ciso_clean) +
  geom_line(aes(x = Date, y = Demand_MW), color = "blue") +
  geom_line(aes(x = Date, y = Predictions), color = "red") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") + 
  labs(x = "Year", y = "Demand (MW)", title = "Demand Time Series by Year") +
  theme_bw()

###########################################################################################

# Handling extreme values

# Using ImputeTS

# identify days that there are missing in demand_ciso_clean
all_dates <- seq(as.Date("2015-07-01"), as.Date("2020-12-31"), by = "day")
dates_difference <- setdiff(all_dates, demand_ciso_clean$Date)
dates_difference_as_dates <- as.Date(dates_difference, origin = "1970-01-01")
print(dates_difference_as_dates)

# do I need to add empty rows of data for these (to ensure that the time series works)?

# create the time series
demand_ciso_ts <- ts(demand_ciso_clean$Demand_MW, 
                     start = min(as.integer(format(as.Date(demand_ciso_clean$Date), "%Y"))), 
                     end = max(as.integer(format(as.Date(demand_ciso_clean$Date), "%Y"))),
                     frequency = 365)

# changing the time series back into a data frame
new_demand_ciso_ts <- data.frame(Time = time(demand_ciso_ts), Value = as.numeric(demand_ciso_ts))
new_demand_ciso_ts$Date <- demand_ciso_clean$Date

# Plot the time series using ggplot2
ggplot(df, aes(x = Time, y = Value)) +
  geom_line() +
  labs(x = "Time", y = "Value", title = "Time Series Plot")

# impute using moving average
# imputed_ciso_data <- na_ma(demand_ciso_ts, k = 5)

# Using Winsorization


# NOTE: Winsorization does not work for BANC data
q <- quantile(demand_banc_clean$Demand_MW, probs = c(0.01, 0.99))
demand_banc_clean$Winsorized_Demand <- demand_banc_clean$Demand_MW 
demand_banc_clean$Winsorized_Demand[demand_banc_clean$Demand_MW < q[1]] <- q[1]  # Clip values below the 1st percentile
demand_banc_clean$Winsorized_Demand[demand_banc_clean$Demand_MW > q[2]] <- q[2]

m3 = lm(data = demand_banc_clean, Winsorized_Demand ~ Month + Year + Weekday)
summary(m3)

demand_banc_clean$Predictions <- predict(m3)

ggplot(demand_banc_clean) +
  geom_line(aes(x = Date, y = Winsorized_Demand), color = "blue") +
  geom_line(aes(x = Date, y = Predictions), color = "red") +
  labs(x = "Year", y = "Demand (MW)", title = "Demand Time Series by Year") +
  theme_bw()


q <- quantile(demand_ciso_clean$Demand_MW, probs = c(0.01, 0.99))
demand_ciso_clean$Winsorized_Demand <- demand_ciso_clean$Demand_MW 
demand_ciso_clean$Winsorized_Demand[demand_ciso_clean$Demand_MW < q[1]] <- q[1]  # Clip values below the 1st percentile
demand_ciso_clean$Winsorized_Demand[demand_ciso_clean$Demand_MW > q[2]] <- q[2]

m4 = lm(data = demand_ciso_clean, Winsorized_Demand ~ Month + Year + Weekday)
summary(m4)

demand_ciso_clean$Predictions <- predict(m4)

ggplot(demand_ciso_clean) +
  geom_line(aes(x = Date, y = Winsorized_Demand), color = "blue") +
  geom_line(aes(x = Date, y = Predictions), color = "red") +
  labs(x = "Year", y = "Demand (MW)", title = "Demand Time Series by Year") +
  theme_bw()








# create low, medium, high demand groups - DO THIS AFTERWORDS
demand_banc_clean$Demand_Category <- cut(data$value, 
                                         breaks = c(), 
                                         labels = c("Low", "Medium", "High"), 
                                         include.lowest = TRUE)

