# run the demand data pull and clean (might have to change link)

source("/Users/sambasala/Desktop/STAT 190/DataCapstone/src/demand_clean.R")

##################################################################################################################

# load in libraries 

library(ggplot2) # for creating gnarly data visualizations

##################################################################################################################

# Time series plots (unimputed)

# BANC
ggplot(demand_banc_clean, aes(x = Date, y = Demand_MW)) +
  geom_line(color = "black") +
  labs(x = "Year", y = "Demand (MW)", title = "BANC Daily Demand") +
  theme_bw()

# CISO
ggplot(demand_ciso_clean, aes(x = Date, y = Demand_MW)) +
  geom_line(color = "black") +
  labs(x = "Year", y = "Demand (MW)", title = "CISO Daily Demand") +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  theme_bw()

# TIDC
ggplot(demand_tidc_clean, aes(x = Date, y = Demand_MW)) +
  geom_line(color = "black") +
  labs(x = "Year", y = "Demand (MW)", title = "TIDC Daily Demand") +
  theme_bw()

# LDWP
ggplot(demand_ldwp_clean, aes(x = Date, y = Demand_MW)) +
  geom_line(color = "black") +
  labs(x = "Year", y = "Demand (MW)", title = "LDWP Daily Demand") +
  theme_bw()

# IID
ggplot(demand_iid_clean, aes(x = Date, y = Demand_MW)) +
  geom_line(color = "black") +
  labs(x = "Year", y = "Demand (MW)", title = "IID Daily Demand") +
  theme_bw()

###########################################################################################

# Steps - do all of these for each region (but go through only one first)

# Create baseline model with all variables
# Look at histograms of variables for model to identify possible transformations
# Look at scatterplots between x variables and y variable
# Remove outliers
# Recreate model with changed variables
# Redo histograms and scatterplots 
# Transform variables if applicable
# Look for collinearity
# Look at residual plot of final model
# Interpret final model

# Hypothesis testing for overall model (commented on) and invidual variables
# Confidence Intervals

###########################################################################################

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

# BANC - problems here still

demand_banc_clean <- remove_outliers(demand_banc_clean)
# create linear model
demand_banc_model <- lm(data = demand_banc_clean, Demand_MW ~ Month + Year + Weekday
                        + Net_Generation_MW + Total_Interchange_MW)
summary(demand_banc_model)
# create predictions
demand_banc_clean$Predictions <- predict(demand_banc_model)

# plot

###########################################################################################

# CISO

# baseline model
demand_ciso_baseline_model <- lm(data = demand_ciso_clean, Demand_MW ~ Month + Year + Weekday)
summary(demand_ciso_baseline_model)
# comment on R^2, F-stat, p-value, residual standard error

# look at histograms and scatterplots of variables
ggplot(data = demand_ciso_clean, aes(x = Year)) + 
  geom_histogram(binwidth = 1, color = "black") +
  labs(title = "Year Frequencies", y = "Frequency") +
  scale_x_continuous(breaks = seq(floor(min(demand_ciso_clean$Year)), ceiling(max(demand_ciso_clean$Year)), by = 1)) + 
  theme_bw()
# normal

ggplot(data = demand_ciso_clean, aes(x = Demand_MW)) + 
  geom_histogram(color = "black") +
  labs(title = "Demand (MW) Frequencies", y = "Frequency") +
  theme_bw()
# slightly left skewed

ggplot(data = demand_ciso_clean, aes(x = Month)) +
  geom_bar(color = "black") +
  labs(y = "Frequency", title = "Month Frequency") +
  theme_bw()
# about the same for each category

ggplot(data = demand_ciso_clean, aes(x = Weekday)) +
  geom_bar(color = "black") +
  labs(y = "Frequency", title = "Weekday Frequency") +
  theme_bw()
# about the same for each category

plot(demand_ciso_clean$Year, demand_ciso_clean$Demand_MW) 
# not helpful

# remove outliers
demand_ciso_clean <- remove_outliers(demand_ciso_clean) 

# recreate linear model
demand_ciso_model <- lm(data = demand_ciso_clean, Demand_MW ~ Month + Year + Weekday)
summary(demand_ciso_model)
# comment on changed R^2, F-stat, p-value, residual standard error

# redo histograms and scatterplots of variables
# look at histograms and scatterplots of variables
ggplot(data = demand_ciso_clean, aes(x = Year)) + 
  geom_histogram(binwidth = 1, color = "black") +
  labs(title = "Year Frequencies", y = "Frequency") +
  scale_x_continuous(breaks = seq(floor(min(demand_ciso_clean$Year)), ceiling(max(demand_ciso_clean$Year)), by = 1)) + 
  theme_bw()
# normal

ggplot(data = demand_ciso_clean, aes(x = Demand_MW)) + 
  geom_histogram(color = "black") +
  labs(title = "Demand (MW) Frequencies", y = "Frequency") +
  scale_x_continuous(labels = function(x) format(x, scientific = FALSE)) +  
  theme_bw()
# slightly left skewed

ggplot(data = demand_ciso_clean, aes(x = Month)) +
  geom_bar(color = "black") +
  labs(y = "Frequency", title = "Month Frequency") +
  theme_bw()
# about the same for each category

ggplot(data = demand_ciso_clean, aes(x = Weekday)) +
  geom_bar(color = "black") +
  labs(y = "Frequency", title = "Weekday Frequency") +
  theme_bw()
# about the same for each category

# all looks well as is, let's continue onto collinearity
# since the F-stat is low and x's appear significant, we can also move on from this

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

# create predictions for the final model 
demand_ciso_clean$Predictions <- predict(demand_ciso_model)

ggplot(demand_ciso_clean) +
  geom_line(aes(x = Date, y = Demand_MW, color = "Actual")) +
  geom_line(aes(x = Date, y = Predictions, color = "Predicted")) +
  labs(x = "Year", y = "Demand (MW)", title = "CISO Daily Demand", color = "Demand") +
  scale_color_manual(values = c("Actual" = "black", "Predicted" = "coral")) +
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +  
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  theme_bw()

###########################################################################################

# IID

demand_iid_clean <- remove_outliers(demand_iid_clean)
# create linear model
demand_iid_model <- lm(data = demand_iid_clean, Demand_MW ~ Month + Year + Weekday)
summary(demand_iid_model)
# create predictions
demand_iid_clean$Predictions <- predict(demand_iid_model)

ggplot(demand_iid_clean) +
  geom_line(aes(x = Date, y = Demand_MW, color = "Actual")) +
  geom_line(aes(x = Date, y = Predictions, color = "Predicted")) +
  labs(x = "Year", y = "Demand (MW)", title = "IID Daily Demand", color = "Demand") +
  scale_color_manual(values = c("Actual" = "black", "Predicted" = "coral")) +
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +  
  theme_bw()

###########################################################################################

# LDWP - data jumps from 09/2015 to 01/2017

demand_ldwp_clean <- remove_outliers(demand_ldwp_clean)
# create linear model
demand_ldwp_model <- lm(data = demand_ldwp_clean, Demand_MW ~ Month + Year + Weekday)
summary(demand_ldwp_model)
# create predictions
demand_ldwp_clean$Predictions <- predict(demand_ldwp_model)

ggplot(demand_ldwp_clean) +
  geom_line(aes(x = Date, y = Demand_MW, color = "Actual")) +
  geom_line(aes(x = Date, y = Predictions, color = "Predicted")) +
  labs(x = "Year", y = "Demand (MW)", title = "LDWP Daily Demand", color = "Demand") +
  scale_color_manual(values = c("Actual" = "black", "Predicted" = "coral")) +
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +  
  theme_bw()

###########################################################################################

# TIDC

demand_tidc_clean <- remove_outliers(demand_tidc_clean)
# create linear model
demand_tidc_model <- lm(data = demand_tidc_clean, Demand_MW ~ Month + Year + Weekday)
summary(demand_tidc_model)
# create predictions
demand_tidc_clean$Predictions <- predict(demand_tidc_model)

ggplot(demand_tidc_clean) +
  geom_line(aes(x = Date, y = Demand_MW, color = "Actual")) +
  geom_line(aes(x = Date, y = Predictions, color = "Predicted")) +
  labs(x = "Year", y = "Demand (MW)", title = "LDWP Daily Demand", color = "Demand") +
  scale_color_manual(values = c("Actual" = "black", "Predicted" = "coral")) +
  scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +  
  theme_bw()

###########################################################################################


# create low, medium, high demand groups - do this later
demand_banc_clean$Demand_Category <- cut(data$value, 
                                         breaks = c(), 
                                         labels = c("Low", "Medium", "High"), 
                                         include.lowest = TRUE)