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
LIVING_COST_DB <- load_living_cost()
DB_MAP <- load_WorldMap()
colname2name_map <- attr(IDB, "colname2name_map")

function(input, output) {
  
  output$gender_imbalance <- gender_imbalance_plot(input, DB_MAP, IDB)
  
  output$living_cost_migration <- living_cost_migration_plot(input, IDB, LIVING_COST_DB)
  
  ###< MAP ###
  worldMapIDB <- reactive({
    filteredYears <- filter(IDB, Year == input$mapYear)
    country_data  <- data.frame(country = filteredYears["Country"], occurrences = filteredYears[input$d4])
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
    
    intervals <- cbreaks(c(lowestNumber, maximumPop), breaks_pretty(breakNumber), labels = comma_format())
    
  })
  
  worldMapDataset <- reactive({
    DB_MAP <- left_join(DB_MAP, worldMapIDB(), by = c("region" = "Country"))
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
    country_data  <- data.frame(country = filteredYears[["Country"]], occurrences = filteredYears[["Total.Fertility.Rate"]])
  })
  
  ### FERTILITY MAP --->###
  output$fertility_map <- renderPlot({
    
    filteredInput <- filteredYearFertiltiy()$occurrences[!is.na(filteredYearFertiltiy()$occurrences)]
    
    minimumPop = min(filteredInput)
    maximumPop = max(filteredInput)
    
    lowestNumber = 0
    
    if (minimumPop < lowestNumber){
      lowestNumber = minimumPop
    }else {
      lowestNumber = 0
    }
    
    color_intervals2 <- cbreaks(c(lowestNumber, maximumPop), breaks_pretty(4), labels = comma_format())
    
    colorLabels = head(color_intervals2$labels, -1)
    colorLabels[1] = paste("Up to", colorLabels[2])
    
    for (i in 2:length(colorLabels)){
      
      if(!is.na(colorLabels[i+1])){
        colorLabels[i] = paste(colorLabels[i], "to", colorLabels[i+1])
      }else{
        colorLabels[i] = paste(colorLabels[i], "and", "more")
      }
      
    }
    
    mergedData <- left_join(DB_MAP, filteredYearFertiltiy(), by = c("region" = "country"))
    
    color_palette <- brewer.pal(length(color_intervals2$breaks), "Greens")
    
    world_map <- ggplot(mergedData) +
      geom_polygon(aes(x = long, y = lat, group = group, fill = cut(occurrences, breaks = color_intervals2$breaks, labels = colorLabels)), color = "gray40") +
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
    country_data  <- data.frame(country = filteredYears[["Country"]], occurrences = filteredYears[["Infant.Mortality.Rate.Both.Sexes"]])
  })
  
  output$infant_map <- renderPlot({
    
    filteredInput <- filteredYearInfant()$occurrences[!is.na(filteredYearInfant()$occurrences)]
    
    minimumPop = min(filteredInput)
    maximumPop = max(filteredInput)
    
    lowestNumber = 0
    
    if (minimumPop < lowestNumber){
      lowestNumber = minimumPop
    }else {
      lowestNumber = 0
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
    
    mergedData <- left_join(DB_MAP, filteredYearInfant(), by = c("region" = "country"))
    
    color_palette <- brewer.pal(length(color_intervals2$breaks), "YlOrRd")
    
    world_map <- ggplot(mergedData) +
      geom_polygon(aes(x = long, y = lat, group = group, fill = cut(occurrences, breaks = color_intervals2$breaks, labels = colorLabels)), color = "gray40") +
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