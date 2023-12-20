gender_imbalance_plot <- function(input, DB_MAP, IDB) {
  worldMapIDB <- reactive({
    IDB_by_year <- filter(IDB, Year == input$year1)
    # male_population = IDB_by_year["Male.Population"]
    # female_population - IDB_by_year["Female.Population"]
    
    country_data  <- data.frame(IDB_by_year["Name"], occurrences = IDB_by_year["Male.Population"])
  })
  
  
  return(renderPlot({
    merged_data <- left_join(DB_MAP, worldMapIDB(), by = c("region" = "Name"))
    minValue = min(merged_data, na.rm = TRUE)
    maxValue = max(merged_data, na.rm = TRUE)
    
    minValue = max(minValue, 0)
    
    
    color_intervals <- cbreaks(c(minValue, maxValue), extended_breaks(5), comma_format())
    color_palette <- brewer.pal(length(color_intervals) - 1, "Blues")
    
    world_map <- ggplot(merged_data) +
      geom_polygon(aes(x = long, y = lat, group = group, fill = cut(Male.Population, breaks = color_intervals)), color = "gray40") +
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
  }))
}
