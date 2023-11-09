library(shiny)
library(ggplot2)
library(dplyr)

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
}