library(shiny)
library(ggplot2)
library(dplyr)
library(tidyverse)
library(maps)
library(RColorBrewer)

source("./preprocess.R")
IDB <- load_IDB()
DB_MAP <- load_WorldMap()
colname2name_map <- attr(IDB, "colname2name_map")

function(input, output) {
  
  dataset <- reactive({
    IDB |>
      select(Year, Name, input$d1, input$d2) |>
      filter(Year >= input$year[1] & Year <= input$year[2] & Name == input$name)
  })
  
  scaleFactor <- reactive({
    max(dataset()[[input$d1]], na.rm = TRUE) / max(dataset()[[input$d2]], na.rm = TRUE)
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
  
  
  
  
  ###< MAP ###
  worldMapIDB <- reactive({
    filteredYears <- filter(IDB, Year == input$mapYear)
    country_data  <- data.frame(country = filteredYears["Name"], occurrences = filteredYears[input$d4])
  
  })
  
  worldMapIntervals <- reactive({
    minimumPop = min(IDB[input$d4])
    maximumPop = max(IDB[input$d4])
    
    lowestNumber = floor(log10(minimumPop))
    higestNumber = floor(log10(maximumPop))
    
    lowBreak = 10 ^ lowestNumber
    highBreak = 10 ^ higestNumber
    
    step1 = lowBreak * 10 - 1 
    step2 = step1 * 10 - 1
    step3 = step2 * 10 - 1
    step4 = step3 * 10 - 1
    
    
    #print(IDB["Population"])
    x = IDB[["Population"]]
    
    #ct = cut(unique(x), breaks = 6)
    
    #print(ct)
    
    #color_intervals <- c(lowBreak,step1, step2, step3, step4, highBreak)
    #color_intervals <- c(lowBreak,999999, 1000000, 9999999 , 10000000, 99999999, 100000000, 249999999, 250000000, highBreak)
    
  })
  
  worldMapDataset <- reactive({
    DB_MAP <- left_join(DB_MAP, worldMapIDB(), by = c("region" = "Name"))
  })
  
  
  ### MAP ###
  output$map <- renderPlot({
    
    d4 <- input$d4

    mapTitle  = paste("World Map for", d4)
    
    color_intervals <- c(0,999999, 1000000, 9999999, 10000000, 99999999, 100000000, 249999999, 250000000, 2000000000)
    
    color_palette <- brewer.pal(length(color_intervals), "YlOrRd")
    
    cnames <- aggregate(cbind(long, lat) ~ region , data=worldMapDataset(), FUN=function(x)mean(range(x)))
    
    world_map <- ggplot(worldMapDataset()) +
      geom_polygon(aes(x = long, y = lat, group = group, fill = cut(.data[[d4]], breaks = color_intervals)), color = "gray40") +
      expand_limits(x = worldMapDataset()$long, y = worldMapDataset()$lat) +
      #geom_text(data = cnames, aes(label = region, x = long, y = lat), size=1) +
      coord_fixed() +
      scale_fill_manual(values = color_palette) +
      labs(title = mapTitle, fill = d4) +
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