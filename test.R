library(shiny)
library(ggplot2)
library(plotly)
library(dplyr)
library(gganimate)
library(gifski)
library(transformr)
library(viridis)
library(plotly)

# Assuming you have a data frame named dff with columns Year, Rent.Index, Groceries.Index, Income, Population, and Country
dff <- read.csv("/Users/sirintra/Documents/exchange sem/study/DV/project/combined_new.csv", header = TRUE,sep = ',')
# Define the UI
ui <- fluidPage(
  titlePanel("Grocery and Renting Index"),
  sidebarLayout(
    sidebarPanel(
      selectInput("year", "Select Year", choices = unique(dff$Year), selected = min(dff$Year)),
      selectInput("continent", "Select Continent", choices = unique(dff$Continent), multiple = TRUE, selected = "Asia")
    ),
    mainPanel(
      plotlyOutput("scatterPlot")
    )
  )
)

# Define the server
server <- function(input, output) {
  
  # Filter data based on the selected year
  filtered_data <- reactive({
    dff %>%
      filter(Year == input$year, Continent %in% input$continent) %>%
      mutate(Income = factor(Income, levels = c("L", "LM", "UM", "H"),
                           labels = c("Low", "Lower Middle", "Upper Middle", "High")))
  })
  
  # Generate the scatter plot
  output$scatterPlot <- renderPlotly({
    
    p <- ggplot(data = filtered_data(), aes(x = Rent.Index, y = Groceries.Index, color = Income, size = Population, text = Country)) +
      geom_point(show.legend = TRUE, alpha = 0.7) +
      #scale_color_viridis_d() +
      scale_color_viridis_d(labels = c("L" = "Low Income", "LM" = "Lower Middle Income", "UM" = "Upper Middle Income", "H" = "High Income")) +
      #scale_color_manual(values = income_labels) +  # Set custom labels
      scale_size(range = c(1, 7)) +
      labs(x = "Rent Index", y = "Groceries Index", color = "Income", size = "Population") +
      geom_text(aes(label = ""), hjust = -0.2, size = 3) +
      shadow_mark(alpha = 0.15) +
      ggtitle(paste("Year:", input$year))
    
    ggplotly(p)
  })
}

# Run the Shiny app
shinyApp(ui, server)
