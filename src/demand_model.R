# run the demand data pull and clean (might have to change link)

source("/Users/sambasala/Desktop/STAT 190/DataCapstone/src/demand_clean.R")

##################################################################################################################

# load in libraries 

library(ggplot2) # for creating gnarly data visualizations

##################################################################################################################

# function to remove outliers from a dataset

remove_outliers <- function(dataset) {
  
  # creating linear regression model
  m1 = lm(data = dataset, Demand_MW ~ Month + Year + Weekday)
  
  # standardized residuals
  rsta = rstandard(m1)
  rsta_indices <- which(rsta < -2 | rsta > 2)
  
  # studentized residuals:
  rstu = rstudent(m1)
  rstu_indices <- which(rstu < -2 | rstu > 2)
  
  # high leverage points
  lev = hatvalues(m1)
  # number of variables in model
  k <- length(coefficients(m1)) - 1
  # number of observations
  n <- as.numeric(nobs(m1))
  # calculate cutoff
  cutoff <- 3*(k + 1) / n
  lev_indices <- which(lev > cutoff)
  
  # Cook's Distance
  cooksd = cooks.distance(m1)
  # Uses F distribution for the cutoff
  df1 <- k + 1
  df2 <- n - (k + 1)
  alpha <- 0.05
  cutoff <- qf(alpha, df1, df2)
  cooks_indices <- which(cooksd > cutoff)
  
  # subset without outliers
  dataset_no_outliers <- dataset[-c(rsta_indices, rstu_indices,
                                    lev_indices, cooks_indices),]
  return(dataset_no_outliers)
  
}

###########################################################################################

# Time series Plots (unimputed)

# BANC
ggplot(demand_banc, aes(x = Date, y = Demand_MW)) +
  geom_line(color = "black") +
  labs(x = "Year", y = "Demand (MW)", title = "BANC Daily Demand") +
  theme_bw()

# CISO
ggplot(demand_ciso, aes(x = Date, y = Demand_MW)) +
  geom_line(color = "black") +
  labs(x = "Year", y = "Demand (MW)", title = "CISO Daily Demand") +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  theme_bw()

# TIDC
ggplot(demand_tidc, aes(x = Date, y = Demand_MW)) +
  geom_line(color = "black") +
  labs(x = "Year", y = "Demand (MW)", title = "TIDC Daily Demand") +
  theme_bw()

# LDWP
ggplot(demand_ldwp, aes(x = Date, y = Demand_MW)) +
  geom_line(color = "black") +
  labs(x = "Year", y = "Demand (MW)", title = "LDWP Daily Demand") +
  theme_bw()

# IID
ggplot(demand_iid, aes(x = Date, y = Demand_MW)) +
  geom_line(color = "black") +
  labs(x = "Year", y = "Demand (MW)", title = "IID Daily Demand") +
  theme_bw()

###########################################################################################

# CISO Modeling

# look at histograms and scatterplots of variables - only for analysis

# Year Histogram
ggplot(data = demand_ciso, aes(x = Year)) + 
  geom_histogram(binwidth = 1, color = "black") +
  labs(title = "Year Frequencies", y = "Frequency") +
  scale_x_continuous(breaks = seq(floor(min(demand_ciso$Year)), ceiling(max(demand_ciso$Year)), by = 1)) + 
  theme_bw()
# normal

# Demand Histogram
ggplot(data = demand_ciso, aes(x = Demand_MW)) + 
  geom_histogram(color = "black") +
  labs(title = "Demand (MW) Frequencies", y = "Frequency") +
  theme_bw()
# slightly left skewed

# Month Frequencies
ggplot(data = demand_ciso, aes(x = Month)) +
  geom_bar(color = "black") +
  labs(y = "Frequency", title = "Month Frequency") +
  theme_bw()
# about the same for each category

# Weekday Frequencies
ggplot(data = demand_ciso, aes(x = Weekday)) +
  geom_bar(color = "black") +
  labs(y = "Frequency", title = "Weekday Frequency") +
  theme_bw()
# about the same for each category
# these need to be in order of the week if presented

# Train/Test Split 
# train: <= 2018
# test: > 2018
demand_ciso_train <- subset(demand_ciso, demand_ciso$Year <= 2018)
demand_ciso_test <- subset(demand_ciso, demand_ciso$Year > 2018)

# Baseline Model
demand_ciso_baseline <- lm(data = demand_ciso_train, Demand_MW ~ Month + Year + Weekday)
summary(demand_ciso_baseline)
# comment on R^2, F-stat, p-value, residual standard error

# create predictions
demand_ciso_train$Predictions <- predict(demand_ciso_baseline, demand_ciso_train)
demand_ciso_test$Predictions <- predict(demand_ciso_baseline, demand_ciso_test)

# recombine the data
demand_ciso <- rbind(demand_ciso_train, demand_ciso_test)

# plot
ggplot(demand_ciso) +
  geom_line(aes(x = Date, y = Demand_MW, color = "Actual")) +
  geom_line(aes(x = Date, y = Predictions, color = "Predicted")) +
  labs(x = "Year", y = "Demand (MW)", title = "CISO Daily Demand", color = "Demand") +
  scale_color_manual(values = c("Actual" = "black", "Predicted" = "red")) +
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +  
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  geom_vline(xintercept = as.numeric(as.Date("2019-01-01")), linetype = "dashed", color = "black") +
  theme_bw()

# residuals and error
residuals <- demand_ciso_test$Demand_MW - demand_ciso_test$Predictions
residual_percent <- residuals / demand_ciso_test$Demand_MW
mse <- mean(residuals^2)
mse_percent <- mean(residual_percent^2)
mean_error <- sqrt(mse)
mean_error_percent <- sqrt(mse_percent)
print(mean_error)
print(mean_error_percent)

# remove outliers
demand_ciso <- remove_outliers(demand_ciso)

# redo histograms and scatterplots of variables - only for analysis

# Time Series
ggplot(demand_ciso, aes(x = Date, y = Demand_MW)) +
  geom_line(color = "black") +
  labs(x = "Year", y = "Demand (MW)", title = "CISO Daily Demand") +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  theme_bw()

# Year Histogram
ggplot(data = demand_ciso, aes(x = Year)) + 
  geom_histogram(binwidth = 1, color = "black") +
  labs(title = "Year Frequencies", y = "Frequency") +
  scale_x_continuous(breaks = seq(floor(min(demand_ciso$Year)), ceiling(max(demand_ciso$Year)), by = 1)) + 
  theme_bw()
# normal

# Demand Histogram
ggplot(data = demand_ciso, aes(x = Demand_MW)) + 
  geom_histogram(color = "black") +
  labs(title = "Demand (MW) Frequencies", y = "Frequency") +
  scale_x_continuous(labels = function(x) format(x, scientific = FALSE)) +  
  theme_bw()
# slight improvement

# Month Frequencies
ggplot(data = demand_ciso, aes(x = Month)) +
  geom_bar(color = "black") +
  labs(y = "Frequency", title = "Month Frequency") +
  theme_bw()
# about the same for each category

# Weekday Frequencies
ggplot(data = demand_ciso, aes(x = Weekday)) +
  geom_bar(color = "black") +
  labs(y = "Frequency", title = "Weekday Frequency") +
  theme_bw()
# about the same for each category
# these need to be in order of the week if presented

# all looks well as is, let's continue onto collinearity
# since the F-stat is low and x's appear significant, we can also move on from this

# New Model

# train/test split
demand_ciso_train <- subset(demand_ciso, demand_ciso$Year <= 2018)
demand_ciso_test <- subset(demand_ciso, demand_ciso$Year > 2018)

# create model based on the training data
demand_ciso_model <- lm(data = demand_ciso_train, Demand_MW ~ Month + Year + Weekday)
summary(demand_ciso_model)
# comment on changed R^2, F-stat, p-value, residual standard error

# Look at residual plot of final model
options(scipen = 100)
plot(residuals(demand_ciso_model) ~ fitted.values(demand_ciso_model), 
     xlab = "Fitted Values",
     ylab = "Residuals",
     main = "Residual Plot")
# In this plot we see random scatter, which is good. This means the linearity 
# assumption is met. 
# However, we do not have some equal variance since we have a slight megaphone shape
# This means the equal variance assumption is mostly met (good enough).

# create predictions
demand_ciso_train$Predictions <- predict(demand_ciso_model, demand_ciso_train)
demand_ciso_test$Predictions <- predict(demand_ciso_model, demand_ciso_test)

# recombine the data
demand_ciso <- rbind(demand_ciso_train, demand_ciso_test)

# plot
ggplot(demand_ciso) +
  geom_line(aes(x = Date, y = Demand_MW, color = "Actual")) +
  geom_line(aes(x = Date, y = Predictions, color = "Predicted")) +
  labs(x = "Year", y = "Demand (MW)", title = "CISO Daily Demand", color = "Demand") +
  scale_color_manual(values = c("Actual" = "black", "Predicted" = "red")) +
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +  
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  geom_vline(xintercept = as.numeric(as.Date("2019-01-01")), linetype = "dashed", color = "black") +
  geom_hline(yintercept = median(demand_ciso$Demand_MW), linetype = "dashed", color = "black") +
  theme_bw()

# residuals and error
residuals <- demand_ciso_test$Demand_MW - demand_ciso_test$Predictions
residual_percent <- residuals / demand_ciso_test$Demand_MW
mse <- mean(residuals^2)
mse_percent <- mean(residual_percent^2)
mean_error <- sqrt(mse)
mean_error_percent <- sqrt(mse_percent)
print(mean_error)
print(mean_error_percent)



# Model to Predict the Future

demand_ciso_future <- data.frame(Date = seq.Date(as.Date("2021-01-01"), as.Date("2021-12-31"), by = "day"))
demand_ciso_future$Year <- as.numeric(format(demand_ciso_future$Date, "%Y"))
demand_ciso_future$Month <- as.factor(format(demand_ciso_future$Date, "%m"))
demand_ciso_future$Weekday <- as.factor(weekdays(demand_ciso_future$Date))

# create model based on all the data
demand_ciso_model_full <- lm(data = demand_ciso, Demand_MW ~ Month + Year + Weekday)
summary(demand_ciso_model_full)
# comment on changed R^2, F-stat, p-value, residual standard error

# Look at residual plot of final model
options(scipen = 100)
plot(residuals(demand_ciso_model_full) ~ fitted.values(demand_ciso_model_full), 
     xlab = "Fitted Values",
     ylab = "Residuals",
     main = "Residual Plot")
# In this plot we see random scatter, which is good. This means the linearity 
# assumption is met. 
# However, we do not have some equal variance since we have a slight megaphone shape
# This means the equal variance assumption is mostly met (good enough).

# create predictions
demand_ciso_future$Predictions <- predict(demand_ciso_model_full, demand_ciso_future)

# plot for predictions
ggplot(demand_ciso_future) +
  geom_line(aes(x = Date, y = Predictions)) +
  labs(x = "Year", y = "Predicted Demand (MW)", title = "CISO Predicted Demand", color = "Demand") +
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +  
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  geom_hline(yintercept = median(demand_ciso_future$Predictions), linetype = "dashed", color = "black") +
  theme_bw()

# figure out what months these are
# try to split data in low, medium, high



###########################################################################################

# Hypothesis testing for overall model (commented on) and invidual variables
# Confidence Intervals