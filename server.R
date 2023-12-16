if(!requireNamespace("shiny",quietly=TRUE))install.packages("shiny")
if(!requireNamespace("dplyr",quietly=TRUE))install.packages("dplyr")
if(!requireNamespace("ggplot2",quietly=TRUE))install.packages("ggplot2")
if(!requireNamespace("maps", quietly=TRUE))install.packages("maps")
if(!requireNamespace("RColorBrewer", quietly=TRUE))install.packages("RColorBrewer")


library(shiny)
library(dplyr)
library(ggplot2)
library(maps)
library(RColorBrewer)

source("./preprocess.R")
IDB <- load_IDB()
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
  
  output$example_map <- renderPlot({
    
    country_data <- data.frame(
      country = c("USA", "Canada", "Brazil", "United Kingdom", "China", "India", "Australia"),
      occurrences = c(20, 15, 30, 10, 25, 15, 20)
    )
    world_data <- map_data("world")
    merged_data <- left_join(world_data, country_data, by = c("region" = "country"))
    
    color_intervals <- c(0, 10, 15, 20, 25, 30)
    color_palette <- brewer.pal(length(color_intervals) - 1, "Greens")
    
    world_map <- ggplot(merged_data) +
      geom_polygon(aes(x = long, y = lat, group = group, fill = cut(occurrences, breaks = color_intervals)), color = "gray40") +
      scale_fill_manual(values = color_palette) +
      labs(title = "World Map for Occurrences", fill = "Occurrences") +
      theme_minimal() +
      theme(legend.position = "bottom") +
      theme(legend.position = "bottom",
            axis.title = element_blank(),
            axis.text = element_blank(),
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank())
    
    print(world_map)
  })
}