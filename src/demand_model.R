# run the demand data pull and clean

source("/Users/sambasala/Desktop/STAT 190/DataCapstone/src/demand_clean.R")

##################################################################################################################

# load in libraries 

library(ggplot2) # for creating clean and professional data visualizations

##################################################################################################################

# Functions for removing outliers and the modeling process
# these functions will be ran for each balancing authority demand subset

# function to remove outliers from a demand dataset
remove_outliers <- function(dataset) {
  
  # create a linear regression model
  m1 = lm(data = dataset, Demand_MW ~ Month + Year + Weekday)
  
  # compute standardized residuals
  rsta = rstandard(m1)
  rsta_indices <- which(rsta < -2 | rsta > 2)
  
  # compute studentized residuals:
  rstu = rstudent(m1)
  rstu_indices <- which(rstu < -2 | rstu > 2)
  
  # compute high leverage points
  lev = hatvalues(m1)
  # k is the number of variables in model
  k <- length(coefficients(m1)) - 1
  # n is the number of observations
  n <- as.numeric(nobs(m1))
  # calculating the cutoff
  cutoff <- 3*(k + 1) / n
  lev_indices <- which(lev > cutoff)
  
  # calculating Cook's Distance
  cooksd = cooks.distance(m1)
  # Using the F distribution for the cutoff, same k and n from above
  df1 <- k + 1
  df2 <- n - (k + 1)
  # chose an alpha of 0.05
  alpha <- 0.05
  cutoff <- qf(alpha, df1, df2)
  cooks_indices <- which(cooksd > cutoff)
  
  # creating a subset with outliers removed
  dataset_no_outliers <- dataset[-c(rsta_indices, rstu_indices,
                                    lev_indices, cooks_indices),]
  
  # returning the subset with outliers removed
  return(dataset_no_outliers)
  
}

# modeling process function
demand_modeling <- function(demand_dataset) {
  
  # plot of the original demand time series for the balancing authority
  og_demand_time_series <- ggplot(demand_dataset, aes(x = Date, y = Demand_MW)) +
    geom_line(color = "black") +
    labs(x = "Year", y = "Demand (MW)", title = "Daily Demand") +
    scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
    scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +  
    theme_bw()
  
  # removing outliers for the given balancing authority subset using the function created above
  demand_dataset <- remove_outliers(demand_dataset)
  
  # new demand time series with outliers removed
  demand_time_series <- ggplot(demand_dataset, aes(x = Date, y = Demand_MW)) +
    geom_line(color = "black") +
    labs(x = "Year", y = "Demand (MW)", title = "Daily Demand") +
    scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
    scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +  
    theme_bw()
  
  # creating a train/test split to be used in the linear regression model
  # train the model on data up to the end of 2018
  demand_dataset_train <- subset(demand_dataset, demand_dataset$Year <= 2018)
  # test the model on data after 2018
  demand_dataset_test <- subset(demand_dataset, demand_dataset$Year > 2018)
  
  # create a linear regression model based on the training data that predicts
  # demand, with month (categorical), year (numeric), and weekday(categorical)
  # as x variables
  demand_model_1 <- lm(data = demand_dataset_train, Demand_MW ~ Month + Year + Weekday)
  
  # create predictions for both the training set and testing set using the model
  # note, the predictions for the training set are important here
  demand_dataset_train$Predictions <- predict(demand_model_1, demand_dataset_train)
  demand_dataset_test$Predictions <- predict(demand_model_1, demand_dataset_test)
  
  # recombine the training and testing data back together to help with visualizations later
  demand_dataset <- rbind(demand_dataset_train, demand_dataset_test)
  
  # obtain the model summary and R^2 for output and to assess model performance
  demand_model_1_summary <- summary(demand_model_1)
  model_1_r_squared <- demand_model_1_summary$r.squared
  
  # calculations to obtain root mean squared error (rmse) to assess model performance
  # residuals
  residuals <- demand_dataset$Demand_MW - demand_dataset$Predictions
  # residuals as a percent
  residual_percent <- residuals / demand_dataset$Demand_MW
  # mean squared error
  mse <- mean(residuals^2)
  # mean squared error as a percent
  mse_percent <- mean(residual_percent^2)
  # root mean squared error (rmse)
  rmse <- sqrt(mse)
  # root mean squared error as a percentage
  rmse_percent <- sqrt(mse_percent)
  
  # linear regression model performance plot
  # shows the actual demand over time vs. the predicted demand from the model
  # there is a x-intercept at 2019 denoting the split between the training and testing dataset
  # there are y-intercepts splitting demand in tertiles to denote demand as "low", "medium", and "high
  model_1_results <- ggplot(demand_dataset) +
    geom_line(aes(x = Date, y = Demand_MW, color = "Actual")) +
    geom_line(aes(x = Date, y = Predictions, color = "Predicted")) +
    labs(x = "Month and Year", y = "Energy Demand (MW)", title = "Daily Energy Demand: Actual vs. Predicted", color = "Demand") +
    scale_color_manual(values = c("Actual" = "black", "Predicted" = "red")) +
    scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +  
    scale_x_date(date_breaks = "3 months", date_labels = "%b %Y") +
    geom_vline(xintercept = as.numeric(as.Date("2019-01-01")), linetype = "dashed", color = "gray") +
    geom_hline(yintercept = quantile(demand_dataset$Demand_MW, 1/3), linetype = "dashed", color = "gray") +
    geom_hline(yintercept = quantile(demand_dataset$Demand_MW, 2/3), linetype = "dashed", color = "gray") +
    theme_bw() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  # Our model is predicting pretty well, so now let's create a new linear regression model 
  # with all our data and use it to predict demand one year into the future

  # create a future dataset containing the date, weekday, month, and year for 2021
  demand_future <- data.frame(Date = seq.Date(as.Date("2021-01-01"), as.Date("2021-12-31"), by = "day"))
  demand_future$Year <- as.numeric(format(demand_future$Date, "%Y"))
  demand_future$Month <- as.factor(format(demand_future$Date, "%m"))
  demand_future$Weekday <- as.factor(weekdays(demand_future$Date))
  
  # create a new linear regression model based on our data before 2021 to predict demand
  demand_model_2 <- lm(data = demand_dataset, Demand_MW ~ Month + Year + Weekday)
  
  # create demand predictions for 2021 in the future dataset with the new model 
  demand_future$Predictions <- predict(demand_model_2, demand_future)
  
  # create a plot displaying 2021 predictions for energy demand
  model_2_results <- ggplot(demand_future) +
    geom_line(aes(x = Date, y = Predictions)) +
    labs(x = "Month and Year", y = "Predicted Energy Demand (MW)", title = "2021 Daily Energy Demand Predictions", color = "Demand") +
    scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +  
    scale_x_date(date_breaks = "1 month", date_labels = "%b %Y") +
    geom_hline(yintercept = quantile(demand_dataset$Demand_MW, 1/3), linetype = "dashed", color = "gray") +
    geom_hline(yintercept = quantile(demand_dataset$Demand_MW, 2/3), linetype = "dashed", color = "gray") +
    theme_bw()
  
  # return the list of data, models, and plots needed for the R Shiny dashboard
  return(list(og_demand_time_series, demand_time_series, demand_model_1, demand_dataset, model_1_results,
              demand_model_2, demand_future, model_2_results, model_1_r_squared, rmse, rmse_percent))

}

##################################################################################################################

# run the demand_modeling() function for each balancing authority demand subset
# and save it under an R variable with common naming conventions
for (name in names(demand_balancing_authority)) {
  # apply the demand_modeling() function to the current balancing authority demand subset
  result <- demand_modeling(demand_balancing_authority[[name]])
  # assign the result to a variable with common naming conventions
  assign(paste0("results_", name), result)
}

# Use saveRDS() to save the result variables for each balancing authority as RDSs to the GitHub output
saveRDS(results_BANC, file = "/Users/sambasala/Desktop/STAT 190/DataCapstone/output/banc_results.rds")
# output to console that everything worked
cat("BANC results saved successfully\n")

saveRDS(results_CISO, file = "/Users/sambasala/Desktop/STAT 190/DataCapstone/output/ciso_results.rds")
cat("CISO results saved successfully\n")

saveRDS(results_IID, file = "/Users/sambasala/Desktop/STAT 190/DataCapstone/output/iid_results.rds")
cat("IID results saved successfully\n")

saveRDS(results_LDWP, file = "/Users/sambasala/Desktop/STAT 190/DataCapstone/output/ldwp_results.rds")
cat("LWDP results saved successfully\n")

saveRDS(results_TIDC, file = "/Users/sambasala/Desktop/STAT 190/DataCapstone/output/tidc_results.rds")
cat("TIDC results saved successfully\n")