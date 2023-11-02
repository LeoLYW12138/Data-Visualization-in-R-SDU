library(shiny)
library(ggplot2)
library(dplyr)

source("./preprocess.R")
IDB <- load_IDB()
names_map <- attr(IDB, "names_map")

function(input, output) {
  
  dataset <- reactive({
    IDB |>
      select(Year, Name, input$d1, input$d2) |>
      filter(Year >= input$year[1] & Year <= input$year[2] & Name == input$name)
  })
  
  
  output$plot <- renderPlot({
    
    p <- ggplot(dataset()) + geom_point(aes(x=Year, y=input$d1)) + geom_point(aes(x=Year, y=input$d2))
    
    print(p)
  })
  
  output$table <- renderTable(dataset())
}