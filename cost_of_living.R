cost_of_living <- function(input, dff, output) {
  
  # Filter data based on the selected year
  filtered_data <- reactive({
    dff %>%
      filter(Year == input$year, Continent %in% input$continent) %>%
      mutate(Income = factor(Income, levels = c("L", "LM", "UM", "H"),
                             labels = c("Low", "Lower Middle", "Upper Middle", "High")))
  })
  
  # Generate the scatter plot
  return(renderPlotly({
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
  })) 
}