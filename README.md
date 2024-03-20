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
    4) data modeling: create time series visualizations for each CAL region, create a simple linear regression predictive model (need low-high categories?). Create dlm package models?
 - DIBA = directly interconnected balancing authority

# Wildfire

# Current Issues
- use population data?
- time series show data impurities that require some hefty changes
- WTS: remind them of our goals, clean CAL region demand data table, ts graph for it, need advice for model predicting demand (fixing impurities, type of model)
