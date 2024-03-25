# STAT 190 Project 1: MidAmerican Energy

Where are the places (regions) that are shrinking/growing in grid demand and are those places at risk of wildfires? Can these two measures quantify a future expected outcome of grid reliability?
- can we predict grid demand (helps understand why demand changes)
- can we predict a wildfire occurring (helps understand why a wildfire occurs)
- can we use those two measures to gain knowledge about expected outcome for grid reliability
  
# To-Do
Trello: https://trello.com/invite/datacapstone3/ATTIaec2913b7e5c31b0741bf3e3937fbb307E7D36D5 

# Bonneville
- source: https://transmission.bpa.gov/Business/Operations/Outages/
- used the 3 different data tables from 2018-2024 to obtain a better understanding of regions, causes, count of causes, and duration of outage
- steps
    1) web-scrape raw data using R
    2) data exploration and create a data dictionary
    3) data cleaning: DESCRIBE
    4) produced visuals to drive new project direction

# Demand
- source: https://www.eia.gov/electricity/gridmonitor/dashboard/electric_overview/US48/US48
- can we predict grid demand
- steps
    1) data pull: read in the demand data files (in GitHub) using R
    2) data cleaning: delete unncessary columns, rename columns, check and change data types, remove NAs through sum aggregation by authority and date, create year and month columns, separate into CAL region authorities 
    4) data modeling: create time series visualizations for each CAL region, created a simple linear regression predictive model (need low-high categories later). Now dealing with data impurities to improve model. Create dlm package models?
 - DIBA = directly interconnected balancing authority

# Wildfire
Wildfire Data:
- Big wildfire data source: https://www.kaggle.com/datasets/behroozsohrabi/us-wildfire-records-6th-edition?select=data.csv
        a. Download data.csv on 2.3 Million US Wildfires (1992-2020) 6th Edition

Weather Data:
- Source: https://open-meteo.com/en/docs/historical-weather-api#latitude=36.7477&longitude=-119.7724&hourly=&daily=weather_code,temperature_2m_max,temperature_2m_min,temperature_2m_mean,apparent_temperature_max,apparent_temperature_min,apparent_temperature_mean,daylight_duration,sunshine_duration,precipitation_sum,rain_sum,snowfall_sum,precipitation_hours,wind_speed_10m_max,wind_gusts_10m_max,wind_direction_10m_dominant,shortwave_radiation_sum,et0_fao_evapotranspiration&temperature_unit=fahrenheit&wind_speed_unit=mph&precipitation_unit=inch&timezone=America%2FLos_Angeles

On the website you type in the city or the longitude and latitude of your 5 points

<img width="926" alt="image" src="https://github.com/SamBa61/STAT190/assets/112500472/1037a9a3-0820-4bf4-8a0a-e249f17fe9f6">

Make sure these are selected

<img width="760" alt="image" src="https://github.com/SamBa61/STAT190/assets/112500472/8196879d-9632-4837-82c8-a7ffae7ebaf4">

Reload and download the CSV

<img width="767" alt="image" src="https://github.com/SamBa61/STAT190/assets/112500472/94d07871-3488-4474-a533-1a58fc38535c">



# Current Issues
- use population data?
- time series show data impurities - can fix these using ImputeTS package
