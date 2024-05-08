library(shiny)
library(shinydashboard)
library(maps) 
library(mapdata)
library(ggplot2)
library(dplyr)
library(rpart) #fitting classification trees
library(rpart.plot) #plotting classification trees
library(pROC) #for creating ROC curves
library(randomForest)
library(lubridate)
library(tidyverse)
library(DT)
library(png)
library(bslib)


ui <- dashboardPage(
  dashboardHeader(title = "Grid Reliability"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Introduction", tabName = "intro", icon = icon("person")),
      menuItem("Research Questions", tabName = "research", icon = icon("question")),
      menuItem("Added Business Value", tabName = "business", icon = icon("arrow-trend-up")),
      menuItem("Demand Model", tabName = "demand", icon = icon("lightbulb")),
      menuItem("Wildfire Model", tabName = "wildfire", icon = icon("fire")),
      menuItem("Predictions", tabName = "pred", icon = icon("bullseye")),
      menuItem("Takeaways", tabName = "takeaways", icon = icon("comments"))
    ),
    selectInput("region", "Select your Region:",
                choices = c("Region 1", "Region 2", "Region 3", "Region 4","Region 5"),
                selected = "Region 3")
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "intro",
              fluidRow(
                box(img(src='sam_basala_mugshot.jpeg', height="100%", width="100%", align = "center"), width = 4),
                box(img(src='isaac_gavin_mugshot.png', height="100%", width="100%", align = "center"), width = 4),
                box(img(src='sam_tucker_mugshot.png', height="100%", width="100%", align = "center"), width = 4)
              ),
              fluidRow(
                box(width = 4,
                  card(
                    card_header(
                      class = "bg_dark",
                      markdown("# **Sam Basala**")
                    ),
                    card_body(
                      markdown("### - Junior, B.S. Data Analytics, Computer Science, and Mathematics \n
                               ### - Plover, WI \n
                               ### - Recently completed my first half marathon")
                    )
                  )
                ),
                box(width = 4,
                    card(
                      card_header(
                        class = "bg_dark",
                        markdown("# **Isaac Gavin**")
                      ),
                      card_body(
                        markdown("### - Senior, B.S. Data Analytics, minors Computer Science, Management \n
                                 ### - Martensdale, IA \n
                                 ### - Working at Corteva and getting married after college.")
                      )
                    )
                ),
                box(width = 4,
                    card(
                      card_header(
                        class = "bg_dark",
                        markdown("# **Sam Tucker**")
                      ),
                      card_body(
                        markdown("### - Senior, B.S. Mathematics, Computer Science, and Data Analytics \n
                                 ### - Winterset, IA \n
                                 ### - Working as a Data Scientist for USDA-NASS after graduation.")
                      )
                    )
                ),
              )),
      tabItem(tabName = "research",
              fluidRow(
                box(width = 12,
                    card(
                      card_header(
                        class = "bg_dark",
                        markdown("# **Research Questions:**")
                      ),
                      card_body(
                        markdown("### 1. Can a *2-dimensional risk model*, which predicts future energy grid demand and the timing of potential wildfires for a chosen region, help improve our understanding of energy grid reliability for that region?
                                 ### 2. Can energy grid demand for the chosen region be predicted one year into the future using the region’s historical balancing authority energy grid demand data?
                                 ### 3. Can wildfires in the region be predicted one year into the future using the region’s historical wildfire and weather data?")
                      )
                    )
                ),
                box(width = 12,
                    card(
                      card_footer(
                        markdown("* *Research focuses on regions in California*
                                  * *Grid Reliability: the ability of the energy grid to consistently keep pace with energy demand (need to consider both the relationship between change in energy demand and the probability of a wildfire)*
                                  * *Energy Demand: the amount of energy needed to satisfy customers and services*")
                      )
                    )
                )
              )),
      tabItem(tabName = "business",
              fluidRow(
                box(width = 12,
                    card(
                      card_header(
                        class = "bg_dark",
                        markdown("# **Added Business Value:**")
                      ),
                      card_body(
                        markdown("## Understanding Future Energy Grid Reliability with a *2-Dimensional Risk Model*
                                  - #### Proper resource allocation
                                  - #### Prevent blackouts
                                  - #### Infrastructure management
                                  - #### Cost management
                                  - #### Ensure reliable energy to customers all the time
                                  ## Energy Demand
                                  - #### Predict and understand the seasonality of grid demand 
                                  ## Wildfire Detection
                                  - #### Predict when and where there is a high probability of a wildfire occurring")
                      )
                    )
                )
              )),
      tabItem(tabName = "demand",
              # Boxes need to be put in a row (or column)
              fluidRow(
                box(verbatimTextOutput("balancing_authority"), width = 12)
              ),
              fluidRow(
                valueBoxOutput("R2", width = 6),
                valueBoxOutput("RMSE", width = 6)
              ),
              fluidRow(
                box(plotOutput("pred_vs_actual", height = 225), width = 12)
              ),
              fluidRow(
                box(plotOutput("pred_future1", height = 225), width = 12)
              ),
              fluidRow(
                box(width = 12,
                    card(
                      card_footer(
                        markdown("* *The data used in these plots and models was collected from a U.S. Energy Information Administration electric grid monitoring dashboard (https://www.eia.gov/electricity/gridmonitor/dashboard/electric_overview/US48/US48), where six-month files of energy balance data from 2015-2020 was downloaded.*
                                  * *Only California balancing authorities were investigated.*")
                      )
                    )
                )
              )),
      tabItem(tabName = "wildfire",
              # Boxes need to be put in a row (or column)
              fluidRow(
                box(verbatimTextOutput("balancing_authority2"), width = 12)
              ),
              fluidRow(
                # render California Map in a box
                box(plotOutput("ca_map", height = 300), width = 5),
                box(plotOutput("importance_plot", height = 300), width = 7)
              ),
              fluidRow(
                box(plotOutput("roc_curve", height = 300), width = 5),
                valueBoxOutput("Sensitivity", width = 7),
                valueBoxOutput("Specificity", width = 7),
                box(width = 7,
                    card(
                      card_footer(
                        markdown("* *Weather data was pulled from a Historical Weather API from 2015-2021- https://open-meteo.com/*
                                  * *Wildfire data was pulled from a comprehensive data set that tracks every wildfire in the country from 2015-2021 - https://www.kaggle.com/datasets/behroozsohrabi/us-wildfire-records-6th-edition?select=data.csv*
                                  * *Only California was investigated*")
                      )
                    )
                )
              )),
      tabItem(tabName = "pred",
              fluidRow(
                box(width = 12,
                  card(
                    card_header(
                      class = "bg_dark",
                      markdown("# **2-Dimensional Risk Model:**")
                    )
                  )
                )
              ),
              fluidRow(
                box(plotOutput("pred_future2", height = 250), width = 12)
              ),
              fluidRow(
                box(plotOutput("pred_wildfire", height = 250),width = 12)
              ),
              fluidRow(
                box(width = 12,
                    card(
                      card_footer(
                        markdown("* *The data used in these plots and models was collected from a U.S. Energy Information Administration electric grid monitoring dashboard, where six-month files of energy balance data from 2015-2020 was downloaded.*
                                  * *Weather data was pulled from a Historical Weather API from 2015-2021- https://open-meteo.com/*
                                  * *Wildfire data was pulled from a comprehensive data set that tracks every wildfire in the country from 2015-2021 - https://www.kaggle.com/datasets/behroozsohrabi/us-wildfire-records-6th-edition?select=data.csv*
                                  * *Only California balancing authorities were investigated.*")
                      )
                    )
                )
              )),
      tabItem(tabName = "takeaways",
              fluidRow(
                box(width = 12,
                    card(
                      card_header(
                        class = "bg_dark",
                        markdown("# **Takeaways:**")
                      ),
                      card_body(
                        markdown("* #### A two-dimensional risk model can help improve our understanding of energy grid reliability for regions in California
                                  * #### Energy demand for regions in California can be predicted one year into the future, with some error
                                  * #### There is some seasonality in California energy demand 
                                       + ##### *Highest during the summer*
                                       + ##### *Higher during the weekdays, lower on the weekends (rolling pattern)*
                                  * #### We can look at California weather patterns and predict when wildfires will occur one year into the future
                                  ### **Future Research:**
                                  - #### Use current energy demand and weather data
                                  - #### Focus research to appropriate company-specific areas
                                  - #### Utilize other weather data, such as vegetation or drought information
                                  - #### Try more advanced modeling techniques, such as dynamic linear models or machine learning algorithms")
                      )
                    ))
              ))
    )
  )
)

server <- function(input, output) {
  #set.seed(122)
  
  r1_banc_results <- readRDS("~/College Classes/Spring 2024/Stat Capstone/code/STAT190/output/r1_banc_results.rds")
  r2_tidc_results <- readRDS("~/College Classes/Spring 2024/Stat Capstone/code/STAT190/output/r2_tidc_results.rds")
  r3_ciso_results <<- readRDS("~/College Classes/Spring 2024/Stat Capstone/code/STAT190/output/r3_ciso_results.rds")
  r4_ldwp_results <- readRDS("~/College Classes/Spring 2024/Stat Capstone/code/STAT190/output/r4_ldwp_results.rds")
  r5_iid_results <- readRDS("~/College Classes/Spring 2024/Stat Capstone/code/STAT190/output/r5_iid_results.rds")
  
  r3_ggROC <- readRDS("~/College Classes/Spring 2024/Stat Capstone/code/STAT190/output/r3_ggROC.rds")
  r3_predictions <- readRDS("~/College Classes/Spring 2024/Stat Capstone/code/STAT190/output/r3_predictions.rds")
  r3_ImportantVariable <- readRDS("~/College Classes/Spring 2024/Stat Capstone/code/STAT190/output/r3_ImportantVariable.rds")
  
  
  # output$samb_pp <- renderImage({
  #   sam_pic <- file.path(paste0("~/College Classes/Spring 2024/Stat Capstone/code/STAT190/output/sam_basala_mugshot.jpeg"))
  #   list(
  #     src = sam_pic
  #   )
  # }, deleteFile = FALSE)

  
  root <<- "C:/Users/Samue/Documents/College Classes/Spring 2024/Stat Capstone/code/STAT190/data/wildfire_datasets/"
  
  # #read in wildfire data from local drive
  all_CA_wild <<- read.csv(paste0(root, "all_CA_wild.csv"), stringsAsFactors = TRUE)
  
  # Get the map data for California
  california_map <<- map_data("state", region = "california")
  
  # Get the map data for California counties
  california_counties <<- map_data("county", region = "california")
  
  output$TwoDRisk <- renderText(
    "2-Dimensional Risk Model"
  )
  
  observeEvent(input$region, {
    if (input$region == "Region 1") {
      output$ca_map <- renderPlot({
        
        # Filter latitude for Central California
        #THESE NUMBERS ARE BASED ON OUR CURRENT 5 CITIES
        CISO_wild <- all_CA_wild %>%
          filter(LATITUDE >= 39 & LATITUDE <= 42)
        
        # California map region
        ggplot() +
          geom_polygon(data = california_map, aes(x = long, y = lat, group = group), 
                       fill = "lightblue", color = "black") +
          
          # Add horizontal lines at LATITUDE 36.4 and 37.8
          geom_hline(yintercept = c(39, 42), linetype = "dashed", color = "black") +
          coord_fixed(1.3) +  # Aspect ratio adjustment
          theme_void() +      # Remove axis and gridlines
          theme(legend.position = "none") + # Remove legend
          labs(title = "Map of California with CISO_Wildfire Data") +
          
          # Add points to the map based on latitude and longitude from the 'wild' dataset
          geom_point(data = CISO_wild, aes(x = LONGITUDE, y = LATITUDE), 
                     color = "red", size = 1)
        
      })
      output$balancing_authority <- renderText(
        "Region 1 // Balancing Authority: Balancing Authority of Northern California (BANC)"
      )
      output$balancing_authority2 <- renderText(
        "Region 1 // Balancing Authority: Balancing Authority of Northern California (BANC)"
      )
      output$pred_vs_actual <- renderPlot({
        r1_banc_results[[5]]
      })
      output$pred_future <- renderPlot({
        r1_banc_results[[8]]
      })
      
    }
    else if (input$region == "Region 2") {
      output$ca_map <- renderPlot({
        
        # Filter latitude for Central California
        #THESE NUMBERS ARE BASED ON OUR CURRENT 5 CITIES
        CISO_wild <- all_CA_wild %>%
          filter(LATITUDE >= 37.8 & LATITUDE <= 39)
        
        # California map region
        ggplot() +
          geom_polygon(data = california_map, aes(x = long, y = lat, group = group), 
                       fill = "lightblue", color = "black") +
          
          # Add horizontal lines at LATITUDE 36.4 and 37.8
          geom_hline(yintercept = c(37.8, 39), linetype = "dashed", color = "black") +
          coord_fixed(1.3) +  # Aspect ratio adjustment
          theme_void() +      # Remove axis and gridlines
          theme(legend.position = "none") + # Remove legend
          labs(title = "Map of California with CISO_Wildfire Data") +
          
          # Add points to the map based on latitude and longitude from the 'wild' dataset
          geom_point(data = CISO_wild, aes(x = LONGITUDE, y = LATITUDE), 
                     color = "red", size = 1)
        
      })
      output$balancing_authority <- renderText(
        "Region 2 // Balancing Authority: Turlock Irrigation District (TIDC)"
      )
      output$balancing_authority2 <- renderText(
        "Region 2 // Balancing Authority: Turlock Irrigation District (TIDC)"
      )
      output$pred_vs_actual <- renderPlot({
        r2_tidc_results[[5]]
      })
      output$pred_future <- renderPlot({
        r2_tidc_results[[8]]
      })
    }
    else if (input$region == "Region 3") {
      output$ca_map <- renderPlot({
        
        # Filter latitude for Central California
        #THESE NUMBERS ARE BASED ON OUR CURRENT 5 CITIES
        CISO_wild <- all_CA_wild %>%
          filter(LATITUDE >= 36.4 & LATITUDE <= 37.8)
        
        # California map region
        ggplot() +
          geom_polygon(data = california_map, aes(x = long, y = lat, group = group), 
                       fill = "lightblue", color = "black") +
          
          # Add horizontal lines at LATITUDE 36.4 and 37.8
          geom_hline(yintercept = c(36.4, 37.8), linetype = "dashed", color = "black") +
          coord_fixed(1.3) +  # Aspect ratio adjustment
          theme_void() +      # Remove axis and gridlines
          theme(legend.position = "none") + # Remove legend
          labs(title = "Map of California with CISO_Wildfire Data") +
          
          # Add points to the map based on latitude and longitude from the 'wild' dataset
          geom_point(data = CISO_wild, aes(x = LONGITUDE, y = LATITUDE), 
                     color = "red", size = 1)
        
      })
      
      output$balancing_authority <- renderText(
        "Region 3 // Balancing Authority: California Independent System Operator (CISO)"
      )
      output$balancing_authority2 <- renderText(
        "Region 3 // Balancing Authority: California Independent System Operator (CISO)"
      )
      
      output$R2 <- renderValueBox({
        valueBox(
          value = formatC(paste0(as.character(round(r3_ciso_results[[9]]*100, digits = 1)), "%"), format = "s"),
          subtitle = "of the variability observed in predicting energy demand is being accounted for by the model",
          icon = icon("magnifying-glass-chart"),
          color = "light-blue",
        )
      })
      output$RMSE <- renderValueBox({
        valueBox(
          value = formatC(paste0(as.character(round(r3_ciso_results[[11]]*100, digits = 1)), "%"), format = "s"),
          subtitle = "on average, the model’s predictions for energy demand are off by this percentage",
          icon = icon("square-root-variable"),
          color = "light-blue",
        )
      })
      
      
      
      output$roc_curve <- renderPlot({
        r3_ggROC
      })
      
      output$importance_plot <- renderPlot({
        r3_ImportantVariable
      })
      
      output$Sensitivity <- renderValueBox({
        valueBox(
          value = formatC("91.7%", format = "s"),
          subtitle = markdown("##### - Out of all the wildfires that will occur in Central California, we estimate we will be able to predict ***91.7%*** of them.
                              ##### - To put this into perspective, if there are typically about 50 wildfires in a year, we accurately anticipated 46 of them."),
          icon = icon("plus"),
          color = "light-blue",
        )
      })
      output$Specificity <- renderValueBox({
        valueBox(
          value = formatC("75.7%", format = "s"),
          subtitle = markdown("##### - Additionally, ***75.7%*** of the time when there was no wildfire in Central California, we correctly predicted that as well.
                              ##### - This means that in a year with 365 days, on the 315 days without a wildfire, our predictions were correct 239 times."),
          icon = icon("minus"),
          color = "light-blue",
        )
      })

      
      output$pred_vs_actual <- renderPlot({
        r3_ciso_results[[5]]
      })
      output$pred_future1 <- renderPlot({
        r3_ciso_results[[8]]
      })
      output$pred_future2 <- renderPlot({
        r3_ciso_results[[8]]
      })
      
      output$pred_wildfire <- renderPlot({
        r3_predictions
      })
      
    }
    else if (input$region == "Region 4") {
      output$ca_map <- renderPlot({
        
        # Filter latitude for Central California
        #THESE NUMBERS ARE BASED ON OUR CURRENT 5 CITIES
        CISO_wild <- all_CA_wild %>%
          filter(LATITUDE >= 34.7 & LATITUDE <= 36.4)
        
        # California map region
        ggplot() +
          geom_polygon(data = california_map, aes(x = long, y = lat, group = group), 
                       fill = "lightblue", color = "black") +
          
          # Add horizontal lines at LATITUDE 36.4 and 37.8
          geom_hline(yintercept = c(34.7, 36.4), linetype = "dashed", color = "black") +
          coord_fixed(1.3) +  # Aspect ratio adjustment
          theme_void() +      # Remove axis and gridlines
          theme(legend.position = "none") + # Remove legend
          labs(title = "Map of California with CISO_Wildfire Data") +
          
          # Add points to the map based on latitude and longitude from the 'wild' dataset
          geom_point(data = CISO_wild, aes(x = LONGITUDE, y = LATITUDE), 
                     color = "red", size = 1)
        
      })
      output$balancing_authority <- renderText(
        "Region 4 // Balancing Authority: Los Angeles Department of Water and Power (LDWP)"
      )
      output$balancing_authority2 <- renderText(
        "Region 4 // Balancing Authority: Los Angeles Department of Water and Power (LDWP)"
      )
      output$pred_vs_actual <- renderPlot({
        r4_ldwp_results[[5]]
      })
      output$pred_future <- renderPlot({
        r4_ldwp_results[[8]]
      })
    }
    else { #if (input$region == "Region 5") {
      output$ca_map <- renderPlot({
        
        # Filter latitude for Central California
        #THESE NUMBERS ARE BASED ON OUR CURRENT 5 CITIES
        CISO_wild <- all_CA_wild %>%
          filter(LATITUDE >= 32.5 & LATITUDE <= 34.7)
        
        # California map region
        ggplot() +
          geom_polygon(data = california_map, aes(x = long, y = lat, group = group), 
                       fill = "lightblue", color = "black") +
          
          # Add horizontal lines at LATITUDE 36.4 and 37.8
          geom_hline(yintercept = c(32.5, 34.7), linetype = "dashed", color = "black") +
          coord_fixed(1.3) +  # Aspect ratio adjustment
          theme_void() +      # Remove axis and gridlines
          theme(legend.position = "none") + # Remove legend
          labs(title = "Map of California with CISO_Wildfire Data") +
          
          # Add points to the map based on latitude and longitude from the 'wild' dataset
          geom_point(data = CISO_wild, aes(x = LONGITUDE, y = LATITUDE), 
                     color = "red", size = 1)
        
      })
      output$balancing_authority <- renderText(
        "Region 5 // Balancing Authority: Imperial Irrigation District (IID)"
      )
      output$balancing_authority2 <- renderText(
        "Region 5 // Balancing Authority: Imperial Irrigation District (IID)"
      )
      output$pred_vs_actual <- renderPlot({
        r5_iid_results[[5]]
      })
      output$pred_future <- renderPlot({
        r5_iid_results[[8]]
      })
    }
  })
}

shinyApp(ui, server)