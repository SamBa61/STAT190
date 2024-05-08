# STAT 190 Project: Understanding Future Energy Grid Reliability
Research Questions:
1. Can a two-dimensional risk model, which predicts future energy grid demand and the timing of potential wildfires for a chosen region, help improve our understanding of energy grid reliability for that region?
2. Can energy grid demand for the chosen region be predicted one year into the future using the region’s historical balancing authority energy grid demand data?
3. Can wildfires in the region be predicted one year into the future using the region’s historical wildfire and weather data?

# Energy Demand (sam-b branch)
Obtaining Data
- Go to U.S. Energy Information Administration energy demand data source: https://www.eia.gov/electricity/gridmonitor/dashboard/electric_overview/US48/US48
- Click “Download Data”
- <img width="1440" alt="Screenshot 2024-05-06 at 11 50 30 AM" src="https://github.com/SamBa61/STAT190/assets/91347135/06d5cbc0-3e6d-4251-a362-07a643d7b9dd">
- Select “Six-Month Files”
- <img width="1440" alt="Screenshot 2024-05-06 at 11 53 29 AM" src="https://github.com/SamBa61/STAT190/assets/91347135/bbd52dc1-8fa3-4263-9e93-39cc6d3bac5a">
- Select and download Six-Month Balance .csv files for years 2015-2020. Please download these files in order from 2015 to 2020.
- <img width="1440" alt="Screenshot 2024-05-06 at 12 00 52 PM" src="https://github.com/SamBa61/STAT190/assets/91347135/a1cc6174-d7b7-4d06-98d4-b46d5cde7baf">
- <img width="1440" alt="Screenshot 2024-05-06 at 12 02 06 PM" src="https://github.com/SamBa61/STAT190/assets/91347135/1dc1ea5c-eb54-4e95-b9b5-bd3f5951f853">
- Save all these .csv files into a folder named data_raw in the Github repository located in the sam-b branch
- Note: the files above are already in the data_raw folder

R and RStudio set-up for running the demand code
- RStudio Version: RStudio 2023.12.0+369 "Ocean Storm" Release (33206f75bd14d07d84753f965eaa24756eda97b7, 2023-12-17) for macOS. Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) RStudio/2023.12.0+369 Chrome/116.0.5845.190 Electron/26.2.4 Safari/537.36
- R Version: R 4.3.2 GUI 1.80 Big Sur ARM build (8281)
- It’s important that the Github repository is cloned locally into RStudio so all the energy demand files that were downloaded can be accessed. All of this work is done in the sam-b branch of the repository.
- R Packages to be installed using install.packages() in the console:
    - dplyr: for data manipulation and pipelining
    - readr: for reading and combining .csv files
    - lubridate: for parsing and manipulating dates more efficiently
    - ggplot2: for creating clean and professional data visualizations

Note: DO NOT RUN OR CHANGE ANY OF THE BELOW FILES

demand_pull_raw.R file: pulling the raw energy demand .csv files into RStudio
- Input: .csv files that were uploaded into the data_raw folder in the Github repository sam-b branch
- Output: demand_all_data dataframe, which contains all of the energy demand .csv file data combined together

demand_clean.R file: cleaning the energy demand data and creating data subsets
- Input: demand_all_data dataframe
    - balancing_authority_list: This list contains the names of the balancing authorities that will be used to create subsets of the energy demand dataframe. BANC, CISO, LDWP, IID, and TIDC are balancing authorities in California, the state we chose to investigate. In future research, these balancing authorities could be changed.
- Output: demand_balancing_authority list, whose elements are the energy demand subset dataframes for each balancing authority from balancing_authority_list

demand_model.R file: creating linear regression models to predict energy demand and assessing those models
- Input: demand_balancing_authority list
- Output: Five results.rds files (one for each balancing authority) that contain demand time series plots, linear regression models predicting demand, metric accessing model performance, and plots accessing model performance. These .rds files get saved into the output folder in the Github repository sam-b branch.

run_all_demand.R: THE ONLY .R FILE THAT NEEDS TO BE RUN FOR THE DEMAND PORTION OF THIS PROJECT
- Run the code in this .R file only. It contains R code that will run the previously described .R programs for you.

# Wildfire & Weather Data (Isaac branch)

For Wildfire R Verison - 2023.12.1

Packages:
- library(maps) #for the California map
- library(mapdata) #for the California map data
- library(ggplot2) #for our ggplots, which is most of them
- library(dplyr) #part of tidyverse for data manipulation
- library(rpart) #fitting classification trees
- library(rpart.plot) #plotting classification trees
- library(pROC) #for creating ROC curves
- library(randomForest) #for random Forest modeling
- library(lubridate) # for dates and times
- library(tidyverse) #for data manipulation

Wildfire Data:
- Big wildfire data source: https://www.kaggle.com/datasets/behroozsohrabi/us-wildfire-records-6th-edition?select=data.csv

    a. Download data.csv on 2.3 Million US Wildfires (1992-2020) 6th Edition

Weather Data:
- If you don't want to go through the website to download the weather data the csv's are in Isaac's branch
- 
- Source: https://open-meteo.com/en/docs/historical-weather-api#latitude=36.7477&longitude=-119.7724&hourly=&daily=weather_code,temperature_2m_max,temperature_2m_min,temperature_2m_mean,apparent_temperature_max,apparent_temperature_min,apparent_temperature_mean,daylight_duration,sunshine_duration,precipitation_sum,rain_sum,snowfall_sum,precipitation_hours,wind_speed_10m_max,wind_gusts_10m_max,wind_direction_10m_dominant,shortwave_radiation_sum,et0_fao_evapotranspiration&temperature_unit=fahrenheit&wind_speed_unit=mph&precipitation_unit=inch&timezone=America%2FLos_Angeles

On the website you type in the city or the longitude and latitude of your 5 points
In this case, the cities that you need to type in are: Oakland name it "Oakland.csv", Benton name it "Benton.csv", Carmel Valley name it "Carmel Valley.csv", Scranton name it "Scranton.csv", and Fresno name it "Fresno.csv"

<img width="926" alt="image" src="https://github.com/SamBa61/STAT190/assets/112500472/1037a9a3-0820-4bf4-8a0a-e249f17fe9f6">

Make sure these are selected

<img width="760" alt="image" src="https://github.com/SamBa61/STAT190/assets/112500472/8196879d-9632-4837-82c8-a7ffae7ebaf4">

Reload and download the CSV

<img width="767" alt="image" src="https://github.com/SamBa61/STAT190/assets/112500472/94d07871-3488-4474-a533-1a58fc38535c">

After all of that is downloaded -> Run wildfiresearch.R

# R Shiny Dashboard
R Verison - 4.3.2

RStudio Version - 2023.12.0+369 "Ocean Storm" Release (33206f75bd14d07d84753f965eaa24756eda97b7, 2023-12-17) for windows
Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) RStudio/2023.12.0+369 Chrome/116.0.5845.190 Electron/26.2.4 Safari/537.36

Packages:
- library(shiny)
- library(shinydashboard)
- library(maps) 
- library(mapdata)
- library(ggplot2)
- library(dplyr)
- library(rpart)
- library(rpart.plot)
- library(pROC)
- library(randomForest)
- library(lubridate)
- library(tidyverse)
- library(DT)
- library(png)
- library(bslib)
