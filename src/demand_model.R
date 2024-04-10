# run the demand data pull and clean (might have to change link)

source("/Users/sambasala/Desktop/STAT 190/DataCapstone/src/demand_clean.R")

##################################################################################################################

# load in libraries 

library(ggplot2) # for creating gnarly data visualizations

##################################################################################################################

# My Glorious Functions

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

# modeling function
demand_modeling <- function(demand_dataset) {
  
  # original time series
  og_demand_time_series <- ggplot(demand_dataset, aes(x = Date, y = Demand_MW)) +
    geom_line(color = "black") +
    labs(x = "Year", y = "Demand (MW)", title = "Daily Demand") +
    scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
    theme_bw()
  
  # remove outliers
  demand_dataset <- remove_outliers(demand_dataset)
  
  # time series w/ outliers removed
  demand_time_series <- ggplot(demand_dataset, aes(x = Date, y = Demand_MW)) +
    geom_line(color = "black") +
    labs(x = "Year", y = "Demand (MW)", title = "Daily Demand") +
    scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
    theme_bw()
  
  # train/test split
  demand_dataset_train <- subset(demand_dataset, demand_dataset$Year <= 2018)
  demand_dataset_test <- subset(demand_dataset, demand_dataset$Year > 2018)
  
  # create model based on the training data
  demand_model_1 <- lm(data = demand_dataset_train, Demand_MW ~ Month + Year + Weekday)
  
  # create predictions
  demand_dataset_train$Predictions <- predict(demand_model_1, demand_dataset_train)
  demand_dataset_test$Predictions <- predict(demand_model_1, demand_dataset_test)
  
  # recombine the data
  demand_dataset <- rbind(demand_dataset_train, demand_dataset_test)
  
  # plot w/ 3-type low/medium/high demand
  model_1_results <- ggplot(demand_dataset) +
    geom_line(aes(x = Date, y = Demand_MW, color = "Actual")) +
    geom_line(aes(x = Date, y = Predictions, color = "Predicted")) +
    labs(x = "Month and Year", y = "Demand (MW)", title = "Daily Demand", color = "Demand") +
    scale_color_manual(values = c("Actual" = "black", "Predicted" = "red")) +
    scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +  
    scale_x_date(date_breaks = "3 months", date_labels = "%b %Y") +
    geom_vline(xintercept = as.numeric(as.Date("2019-01-01")), linetype = "dashed", color = "black") +
    geom_hline(yintercept = quantile(demand_dataset$Demand_MW, 1/3), linetype = "dashed", color = "black") +
    geom_hline(yintercept = quantile(demand_dataset$Demand_MW, 2/3), linetype = "dashed", color = "black") +
    theme_bw() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  # Model to Predict the Future
  demand_future <- data.frame(Date = seq.Date(as.Date("2021-01-01"), as.Date("2021-12-31"), by = "day"))
  demand_future$Year <- as.numeric(format(demand_future$Date, "%Y"))
  demand_future$Month <- as.factor(format(demand_future$Date, "%m"))
  demand_future$Weekday <- as.factor(weekdays(demand_future$Date))
  
  # create model based on all the data before 2021
  demand_model_2 <- lm(data = demand_dataset, Demand_MW ~ Month + Year + Weekday)
  
  # create predictions
  demand_future$Predictions <- predict(demand_model_2, demand_future)
  
  # plot for predictions
  model_2_results <- ggplot(demand_future) +
    geom_line(aes(x = Date, y = Predictions)) +
    labs(x = "Month and Year", y = "Predicted Demand (MW)", title = "Predicted Demand", color = "Demand") +
    scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +  
    scale_x_date(date_breaks = "1 month", date_labels = "%b %Y") +
    geom_hline(yintercept = quantile(demand_dataset$Demand_MW, 1/3), linetype = "dashed", color = "black") +
    geom_hline(yintercept = quantile(demand_dataset$Demand_MW, 2/3), linetype = "dashed", color = "black") +
    theme_bw() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))

  # return list of data, models, and plots
  return(list(og_demand_time_series, demand_time_series, demand_model_1, demand_dataset, model_1_results,
              demand_model_2, demand_future, model_2_results))

}

##################################################################################################################

results <- lapply(names(demand_balancing_authority), function(name) {
  assign(paste0("result_", name), demand_modeling(demand_balancing_authority[[name]]))
})

for (name in names(demand_balancing_authority)) {
  # Apply the function to the current data frame
  result <- demand_modeling(demand_balancing_authority[[name]])
  
  # Assign the result to a variable with a unique name
  assign(paste0("results_", name), result, envir = .GlobalEnv)
}





