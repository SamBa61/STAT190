# for (balancing_authority in balancing_authority_list) {
#   subset_name <- paste0("demand_", tolower(balancing_authority))
#   subset_data <- assign(subset_name, subset(demand_clean, Balancing_Authority == balancing_authority))
#   subset_data$Demand_Category_Bin <- as.factor(ifelse(subset_data$Demand_MW >= median(subset_data$Demand_MW), "High", "Low"))
#   subset_data$Demand_Category <- as.factor(cut(subset_data$Demand_MW, breaks = c(min(subset_data$Demand_MW), quantile(subset_data$Demand_MW, 1/3), quantile(subset_data$Demand_MW, 2/3), max(subset_data$Demand_MW)), labels = c("Low", "Medium", "High")))
#   assign(subset_name, subset_data)
# }

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

# Remove Outliers

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

# residuals and error
residuals <- demand_ciso_test$Demand_MW - demand_ciso_test$Predictions
residual_percent <- residuals / demand_ciso_test$Demand_MW
mse <- mean(residuals^2)
mse_percent <- mean(residual_percent^2)
mean_error <- sqrt(mse)
mean_error_percent <- sqrt(mse_percent)
print(mean_error)
print(mean_error_percent)

# plot w/ binary low/high demand
ggplot(demand_ciso) +
  geom_line(aes(x = Date, y = Demand_MW, color = "Actual")) +
  geom_line(aes(x = Date, y = Predictions, color = "Predicted")) +
  labs(x = "Month and Year", y = "Demand (MW)", title = "CISO Daily Demand", color = "Demand") +
  scale_color_manual(values = c("Actual" = "black", "Predicted" = "red")) +
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +  
  scale_x_date(date_breaks = "3 months", date_labels = "%b %Y") +
  geom_vline(xintercept = as.numeric(as.Date("2019-01-01")), linetype = "dashed", color = "black") +
  geom_hline(yintercept = median(demand_ciso$Demand_MW), linetype = "dashed", color = "black") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# plot w/ 3-type low/medium/high demand
ggplot(demand_ciso) +
  geom_line(aes(x = Date, y = Demand_MW, color = "Actual")) +
  geom_line(aes(x = Date, y = Predictions, color = "Predicted")) +
  labs(x = "Month and Year", y = "Demand (MW)", title = "CISO Daily Demand", color = "Demand") +
  scale_color_manual(values = c("Actual" = "black", "Predicted" = "red")) +
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +  
  scale_x_date(date_breaks = "3 months", date_labels = "%b %Y") +
  geom_vline(xintercept = as.numeric(as.Date("2019-01-01")), linetype = "dashed", color = "black") +
  geom_hline(yintercept = quantile(demand_ciso$Demand_MW, 1/3), linetype = "dashed", color = "black") +
  geom_hline(yintercept = quantile(demand_ciso$Demand_MW, 2/3), linetype = "dashed", color = "black") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# NOTE: SUMMER IS MOST IMPORTANT

# Model to Predict the Future

demand_ciso_future <- data.frame(Date = seq.Date(as.Date("2021-01-01"), as.Date("2021-12-31"), by = "day"))
demand_ciso_future$Year <- as.numeric(format(demand_ciso_future$Date, "%Y"))
demand_ciso_future$Month <- as.factor(format(demand_ciso_future$Date, "%m"))
demand_ciso_future$Weekday <- as.factor(weekdays(demand_ciso_future$Date))

# create model based on all the data before 2021
demand_ciso_model_full <- lm(data = demand_ciso, Demand_MW ~ Month + Year + Weekday)
summary(demand_ciso_model_full)
# comment on changed R^2, F-stat, p-value, residual standard error
# weekend LOW
# Wed HIGH

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
  labs(x = "Month and Year", y = "Predicted Demand (MW)", title = "CISO Predicted Demand", color = "Demand") +
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +  
  scale_x_date(date_breaks = "1 month", date_labels = "%b %Y") +
  geom_hline(yintercept = quantile(demand_ciso$Demand_MW, 1/3), linetype = "dashed", color = "black") +
  geom_hline(yintercept = quantile(demand_ciso$Demand_MW, 2/3), linetype = "dashed", color = "black") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

