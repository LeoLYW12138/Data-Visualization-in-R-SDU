gender_imbalance_plot <- function(input, DB_MAP, IDB) {
  worldMapIDB <- reactive({
    IDB_by_year <- filter(IDB, Year == input$year1)
    male_population <- IDB_by_year[["Male.Population"]]
    female_population <- IDB_by_year[["Female.Population"]]
    gender_ratio <- male_population / female_population * 100
    
    country_data  <- data.frame(country = IDB_by_year[["Country"]], gender_ratio)
  })
  
  merged_data <- reactive({
    merged_data <- left_join(DB_MAP, worldMapIDB(), by = c("region" = "country"))
  })
  
  
  return(renderPlot({
    
    minValue = min(merged_data()$gender_ratio, na.rm = TRUE)
    maxValue = max(merged_data()$gender_ratio, na.rm = TRUE)
    
    minValue = max(minValue, 0)
    
    color_intervals <- cbreaks(c(minValue, maxValue), extended_breaks(5), comma_format())
    color_palette <- brewer.pal(length(color_intervals$breaks) - 1, "Blues")
    world_map <- ggplot(merged_data()) +
      geom_polygon(aes(x = long, y = lat, group = group, fill = cut(gender_ratio, breaks = color_intervals$breaks, labels=head(color_intervals$labels, -1))), color = "gray40") +
      scale_fill_manual(values = color_palette) +
      labs(title = "World Map for Male Population", fill = "Gender ratio") +
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
