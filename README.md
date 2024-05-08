# Energy Demand (sam-b branch)
Obtaining Data
- Go to data source: https://www.eia.gov/electricity/gridmonitor/dashboard/electric_ overview/US48/US48
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
