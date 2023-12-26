if(!requireNamespace("shiny",quietly=TRUE))install.packages("shiny")
if(!requireNamespace("dplyr",quietly=TRUE))install.packages("dplyr")
if(!requireNamespace("ggplot2",quietly=TRUE))install.packages("ggplot2")
if(!requireNamespace("gganimate",quietly=TRUE))install.packages("gganimate")
if(!requireNamespace("gifski",quietly=TRUE))install.packages("gifski")
if(!requireNamespace("RColorBrewer", quietly=TRUE))install.packages("RColorBrewer")
if(!requireNamespace("moments", quietly=TRUE))install.packages("moments")
if(!requireNamespace("scales", quietly=TRUE))install.packages("scales")

library(shiny)
library(dplyr)
library(tidyverse)
library(RColorBrewer)
library(moments)
library(scales)
library(ggplot2)
library(gganimate)

source("./preprocess.R")
source("./gender_imbalance_plot.R")
source("./living_cost_migration_plot.R")
IDB <- load_IDB()
DB_MAP <- load_WorldMap()
colname2name_map <- attr(IDB, "colname2name_map")

function(input, output) {
  
  dataset <- reactive({
    IDB |>
      select(Year, Country, input$d1, input$d2) |>
      filter(Year >= input$year[1] & Year <= input$year[2] & Country == input$name)
  })
  
  scaleFactor <- reactive({
    m <- max(dataset()[[input$d1]], na.rm = TRUE) / max(dataset()[[input$d2]], na.rm = TRUE)
  })
  
  output$tab1_plot <- renderPlot({
    
    d1 <- input$d1
    d2 <- input$d2
    
    p <- ggplot(dataset()) + 
      geom_line(aes(x=Year, y=.data[[d1]])) + 
      geom_point(aes(x=Year, y=.data[[d1]])) +
      # geom_text(aes(x = Year, y = .data[[input$d1]], label=.data[[input$d1]]),vjust=-0.25) +
      geom_line(aes(x=Year, y=.data[[d2]] * scaleFactor()), color="red") +
      geom_point(aes(x=Year, y=.data[[d2]] * scaleFactor()), color="red")+
      # geom_text(aes(x = Year, y = .data[[input$d2]], label=.data[[input$d2]]),vjust=-0.25, color="red") +
      scale_y_continuous(name=colname2name_map[d1], sec.axis=sec_axis(~./scaleFactor(), name=colname2name_map[d2])) +
      theme(
        axis.title.y.left=element_text(),
        axis.text.y.left=element_text(),
        axis.title.y.right=element_text(color="red"),
        axis.text.y.right=element_text(color="red")
      )
      labs(x = "Year", y = input$d1)
    print(p)
  })
  
  output$table <- renderTable(dataset())
  
  output$gender_imbalance <- gender_imbalance_plot(input, DB_MAP, IDB)
  
  output$living_cost_migration <- living_cost_migration_plot(input, IDB, output)
  
  ###< MAP ###
  worldMapIDB <- reactive({
    filteredYears <- filter(IDB, Year == input$mapYear)
    country_data  <- data.frame(country = filteredYears["Country"], occurrences = filteredYears[input$d4])
  })
  
  worldMapIntervals <- reactive({
    d4 <- input$d4
    
    d4 = gsub(r"{\s*\([^\)]+\)}","",as.character(d4))
    
    if(d4 == "Population.Density."){
      d4 <- "Population.Density..People.per.Sq..Km.."
    }
    
    if(d4 == "Annual.Growth.Rate.%"){
      d4 <- "Annual.Growth.Rate.."
    }
    
    filteredInput <- worldMapIDB()[d4][!is.na(worldMapIDB()[d4])]
    
    minimumPop = min(filteredInput)
    maximumPop = max(filteredInput)
    
    print(minimumPop)
    print(maximumPop)
    
    lowestNumber = 0
    
    if (minimumPop < lowestNumber){
      lowestNumber = minimumPop
    }else {
      lowestNumber = 0
    }
    
    breakNumber = 7
    
    if (maximumPop > 1000){
      breakNumber = 12
    }else if (maximumPop < 10){
      breakNumber = 5
    }else{
      breakNumber = 7
    }
    
    if (d4 == "Population.Density..People.per.Sq..Km.."){
      breakNumber = 7
      maximumPop = 600
    }
    
    intervals <- cbreaks(c(lowestNumber, maximumPop), breaks_pretty(breakNumber), labels = comma_format())
    
  })
  
  worldMapDataset <- reactive({
    DB_MAP <- left_join(DB_MAP, worldMapIDB(), by = c("region" = "Country"))
  })
  
  
  ### MAP ###
  output$map <- renderPlot({
    
    d4 <- input$d4
    
    d4 = gsub(r"{\s*\([^\)]+\)}","",as.character(d4))
    
    if(d4 == "Population.Density."){
      d4 <- "Population.Density..People.per.Sq..Km.."
    }
    
    if(d4 == "Annual.Growth.Rate.%"){
      d4 <- "Annual.Growth.Rate.."
    }
    
    
    color_intervals2 <- worldMapIntervals()
    
    colorLabels = head(color_intervals2$labels, -1)
   
    colorLabels[1] = paste("Up to", colorLabels[2])
    
    for (i in 2:length(colorLabels)){
      
      if(!is.na(colorLabels[i+1])){
        colorLabels[i] = paste(colorLabels[i], "to", colorLabels[i+1])
      }else{
        colorLabels[i] = paste(colorLabels[i], "and", "more")
      }

    }
    
    title <- gsub("\\.(?=[^.]*\\.)", " ", d4, perl=TRUE)
    mapTitle  = paste("World Map for", title)
    
    color_palette <- brewer.pal(length(color_intervals2$breaks), "YlOrRd")
    
    #Need to filter out names not fit
    cnames <- aggregate(cbind(long, lat) ~ region , data=worldMapDataset(), FUN=function(x)median(range(x)))
    
    world_map <- ggplot(worldMapDataset()) +
      geom_polygon(aes(x = long, y = lat, group = group, fill = cut(.data[[d4]], breaks = color_intervals2$breaks, labels = colorLabels)), color = "gray40") +
      expand_limits(x = worldMapDataset()$long, y = worldMapDataset()$lat) +
      #geom_text(data = cnames, aes(label = region, x = long, y = lat), size=2) +
      coord_fixed() +
      scale_fill_manual(values = color_palette) +
      labs(title = mapTitle, fill = title) +
      theme_minimal() +
      theme(legend.position = "bottom") +
      theme(legend.position = "bottom",
            axis.title = element_blank(),
            axis.text = element_blank(),
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank())
    
    print(world_map)
    
  })
  ### MAP >###
  
}