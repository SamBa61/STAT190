# Use this file to run all the demand data processes
# PLEASE RUN IN ORDER

source("src/demand_pull_raw.R")
source("src/demand_clean.R")
source("src/demand_model.R")