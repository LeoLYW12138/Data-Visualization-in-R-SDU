if(!requireNamespace("shiny",quietly=TRUE))install.packages("shiny")
if(!requireNamespace("dplyr",quietly=TRUE))install.packages("dplyr")
if(!requireNamespace("ggplot2",quietly=TRUE))install.packages("ggplot2")
if(!requireNamespace("maps", quietly=TRUE))install.packages("maps")
if(!requireNamespace("RColorBrewer", quietly=TRUE))install.packages("RColorBrewer")


library(shiny)
library(dplyr)
library(tidyverse)
library(maps)
library(RColorBrewer)
library(moments)
library(scales)

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
  
  worldMapDataset <- reactive({
    DB_MAP <- left_join(DB_MAP, worldMapIDB(), by = c("region" = "Name"))
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
      breakNumber = 4
    }else{
      breakNumber = 6
    }
    
    
    if (d4 == "Population.Density..People.per.Sq..Km.."){
      breakNumber = 7
      maximumPop = 600
    }
    
    if (d4 == "Net.international.migrants.both.sexes"){
      breakNumber = 4
      maximumPop = 1000
    }
    
    intervals <- cbreaks(c(lowestNumber, maximumPop), breaks_pretty(breakNumber), labels = comma_format())
    
  })
  
  
  ### OVERALL MAP --->###
  output$map <- renderPlot({
    
    d4 <- input$d4
    
    #Cleaning input due to change of column names when joining
    d4 = gsub(r"{\s*\([^\)]+\)}","",as.character(d4))
    
    if(d4 == "Population.Density."){
      d4 <- "Population.Density..People.per.Sq..Km.."
    }
    
    if(d4 == "Annual.Growth.Rate.%"){
      d4 <- "Annual.Growth.Rate.."
    }
    
    
    #Loading the proper intervals for the data and creating labels for them
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
    
    #Clean input for title and map title
    title <- gsub("\\.(?=[^.]*\\.)", " ", d4, perl=TRUE)
    mapTitle  = paste("World Map for", title)
    
    color_palette <- brewer.pal(length(color_intervals2$breaks), "YlOrRd")
    
    filteredWorldMap <- worldMapDataset() %>% select(long,lat, region)
    
    #First summarize the region's mean to get the location of the country names to be put on the map
    cnames  <- filteredWorldMap %>% group_by(region) %>% summarise_all(mean)
    filterList <- c("China", "Russia", "Brazil", "Australia", "India")
    cnames <- filter(cnames, region %in% filterList)
    
    print(color_intervals2$breaks)
    print(title)
    
    world_map <- ggplot(worldMapDataset()) +
      geom_polygon(aes(x = long, y = lat, group = group, fill = cut(.data[[d4]], breaks = color_intervals2$breaks, labels = colorLabels)), color = "gray40") +
      expand_limits(x = worldMapDataset()$long, y = worldMapDataset()$lat) +
      geom_text(data = cnames,
                aes(label = region, x = long, y = lat), size = 3, fontface = 2, color = "gray20") +
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
  ###<--- OVERALL MAP###
  
  filteredYearFertiltiy <- reactive({
    filteredYears <- filter(IDB, Year == input$mapYearFertility)
    country_data  <- data.frame(country = filteredYears["Name"], occurrences = filteredYears["Total.Fertility.Rate"])
  })
  
  ### FERTILITY MAP --->###
  output$fertility_map <- renderPlot({
    
    filteredInput <- filteredYearFertiltiy()$Total.Fertility.Rate[!is.na(filteredYearFertiltiy()$Total.Fertility.Rate)]
    
    minimumPop = min(filteredInput)
    maximumPop = max(filteredInput)
    
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
      breakNumber = 4
    }else{
      breakNumber = 6
    }
    
    color_intervals2 <- cbreaks(c(lowestNumber, maximumPop), breaks_pretty(breakNumber), labels = comma_format())
    
    colorLabels = head(color_intervals2$labels, -1)
    colorLabels[1] = paste("Up to", colorLabels[2])
    
    for (i in 2:length(colorLabels)){
      
      if(!is.na(colorLabels[i+1])){
        colorLabels[i] = paste(colorLabels[i], "to", colorLabels[i+1])
      }else{
        colorLabels[i] = paste(colorLabels[i], "and", "more")
      }
      
    }
    
    mergedData <- left_join(DB_MAP, filteredYearFertiltiy(), by = c("region" = "Name"))
    
    color_palette <- brewer.pal(length(color_intervals2$breaks), "Greens")
    
    world_map <- ggplot(mergedData) +
      geom_polygon(aes(x = long, y = lat, group = group, fill = cut(Total.Fertility.Rate, breaks = color_intervals2$breaks, labels = colorLabels)), color = "gray40") +
      coord_fixed() +
      scale_fill_manual(values = color_palette) +
      labs(title = "World Map of Fertility Rate", fill = "Births per woman") +
      theme_minimal() +
      theme(legend.position = "bottom") +
      theme(legend.position = "bottom",
            axis.title = element_blank(),
            axis.text = element_blank(),
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank())
    
    print(world_map)
  })
  ###<--- FERTILITY MAP###
  
  ### INFANT MORTALITY MAP --->###
  filteredYearInfant <- reactive({
    filteredYears <- filter(IDB, Year == input$mapYearInfant)
    country_data  <- data.frame(country = filteredYears["Name"], occurrences = filteredYears["Infant.Mortality.Rate.Both.Sexes"])
  })
  
  output$infant_map <- renderPlot({
    
    filteredInput <- filteredYearInfant()$Infant.Mortality.Rate.Both.Sexes[!is.na(filteredYearInfant()$Infant.Mortality.Rate.Both.Sexes)]
    
    minimumPop = min(filteredInput)
    maximumPop = max(filteredInput)
    
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
      breakNumber = 4
    }else{
      breakNumber = 6
    }
    
    color_intervals2 <- cbreaks(c(lowestNumber, maximumPop), breaks_pretty(5), labels = comma_format())
    
    colorLabels = head(color_intervals2$labels, -1)
    colorLabels[1] = paste("Up to", colorLabels[2])
    
    for (i in 2:length(colorLabels)){
      if(!is.na(colorLabels[i+1])){
        colorLabels[i] = paste(colorLabels[i], "to", colorLabels[i+1])
      }else{
        colorLabels[i] = paste(colorLabels[i], "and", "more")
      }
    }
    
    mergedData <- left_join(DB_MAP, filteredYearInfant(), by = c("region" = "Name"))
    
    color_palette <- brewer.pal(length(color_intervals2$breaks), "YlOrRd")
    
    print(color_intervals2)
    print(mergedData)
    
    world_map <- ggplot(mergedData) +
      geom_polygon(aes(x = long, y = lat, group = group, fill = cut(Infant.Mortality.Rate.Both.Sexes, breaks = color_intervals2$breaks, labels = colorLabels)), color = "gray40") +
      coord_fixed() +
      scale_fill_manual(values = color_palette) +
      labs(title = "World Map of Infant Mortality Rate, Both Sexes", fill = "Deaths per 1,000 live births") +
      theme_minimal() +
      theme(legend.position = "bottom") +
      theme(legend.position = "bottom",
            axis.title = element_blank(),
            axis.text = element_blank(),
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank())
    
    print(world_map)
  })
  ### <--- INFANT MORTALITY MAP###
  
}