# STAT 190 Project 1: MidAmerican Energy

Where are the places (regions) that are shrinking/growing in grid demand and are those places at risk of wildfires? Can these two measures quantify a future expected outcome of grid reliability?
- can we predict grid demand (helps understand why demand changes)
- can we predict a wildfire occurring (helps understand why a wildfire occurs)
- can we use those two measures to gain knowledge about expected outcome for grid reliability

# Demand
- source: https://www.eia.gov/electricity/gridmonitor/dashboard/electric_overview/US48/US48
- can we predict grid demand
- steps
    1) read in the demand data files (in GitHub) using R
    2) data exploration
    3) data cleaning: handling NAs, aggregating to days, and creating low-mid-high categories for demand
    4) create visualizations with clean data
    5) create predictive model for demand
 - DIBA = directly interconnected balancing authority

# Wildfire & Weather Data
Packages:
library(maps) #for the California map
library(mapdata) #for the California map data
library(ggplot2) #for our ggplots, which is most of them
library(dplyr) #part of tidyverse for data manipulation
library(rpart) #fitting classification trees
library(rpart.plot) #plotting classification trees
library(pROC) #for creating ROC curves
library(randomForest) #for random Forest modeling
library(lubridate) # for dates and times
library(tidyverse) #for data manipulation

Wildfire Data:
- Big wildfire data source: https://www.kaggle.com/datasets/behroozsohrabi/us-wildfire-records-6th-edition?select=data.csv

    a. Download data.csv on 2.3 Million US Wildfires (1992-2020) 6th Edition

Weather Data:
- Source: https://open-meteo.com/en/docs/historical-weather-api#latitude=36.7477&longitude=-119.7724&hourly=&daily=weather_code,temperature_2m_max,temperature_2m_min,temperature_2m_mean,apparent_temperature_max,apparent_temperature_min,apparent_temperature_mean,daylight_duration,sunshine_duration,precipitation_sum,rain_sum,snowfall_sum,precipitation_hours,wind_speed_10m_max,wind_gusts_10m_max,wind_direction_10m_dominant,shortwave_radiation_sum,et0_fao_evapotranspiration&temperature_unit=fahrenheit&wind_speed_unit=mph&precipitation_unit=inch&timezone=America%2FLos_Angeles

On the website you type in the city or the longitude and latitude of your 5 points
In this case, the cities that you need to type in are: Oakland name it "Oakland.csv", Benton name it "Benton.csv", Carmel Valley name it "Carmel Valley.csv", Scranton name it "Scranton.csv", and Fresno name it "Fresno.csv"

<img width="926" alt="image" src="https://github.com/SamBa61/STAT190/assets/112500472/1037a9a3-0820-4bf4-8a0a-e249f17fe9f6">

Make sure these are selected

<img width="760" alt="image" src="https://github.com/SamBa61/STAT190/assets/112500472/8196879d-9632-4837-82c8-a7ffae7ebaf4">

Reload and download the CSV

<img width="767" alt="image" src="https://github.com/SamBa61/STAT190/assets/112500472/94d07871-3488-4474-a533-1a58fc38535c">

After all of that is downloaded -> Run wildfiresearch.R
