gender_imbalance_plot <- function(input, DB_MAP, IDB) {
  worldMapIDB <- reactive({
    IDB_by_year <- filter(IDB, Year == input$year_gender_imbalance)
    male_population <- IDB_by_year[["Male.Population"]]
    female_population <- IDB_by_year[["Female.Population"]]
    gender_ratio <- male_population / female_population * 100
    
    country_data  <-
      data.frame(country = IDB_by_year[["Country"]], gender_ratio, Income = IDB_by_year[["Income"]])
  })
  
  merged_data <- reactive({
    merged_data <-
      left_join(DB_MAP, worldMapIDB(), by = c("region" = "country"))
  })
  
  
  return(renderPlot({
    minValue = min(merged_data()$gender_ratio, na.rm = TRUE)
    maxValue = max(merged_data()$gender_ratio, na.rm = TRUE)
    
    minValue = max(minValue, 0)
    
    # color_intervals <- cbreaks(c(minValue, maxValue), extended_breaks(9), comma_format())
    color_intervals = list(
      breaks = c(90, 95, 100, 105, 110, 115, 120, 300),
      labels = c(
        "0-90",
        "90-95",
        "95-100",
        "100-105",
        "105-110",
        "110-115",
        "115+"
      )
    )
    display.brewer.all(colorblindFriendly = TRUE)
    p <-
      ggplot(merged_data(), aes(x = long, y = lat, group = group)) +
      geom_polygon(aes(
        fill = cut(
          gender_ratio,
          breaks = color_intervals$breaks,
          labels = color_intervals$labels
        )
      ), color = "gray40") +
      scale_fill_brewer(palette = "Blues", na.value = "grey40") +
      labs(title = "Gender ratio in the world", fill = "Male to Female %", caption="dark color means more male than female") +
      theme_minimal() +
      coord_fixed() +
      
      theme(legend.position = "bottom") +
      theme(
        legend.position = "bottom",
        axis.title = element_blank(),
        axis.text = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank()
      )
    
    if (input$show_income_level_gender_imbalance) {
      p <- p + geom_polygon(aes(color = Income), fill = NA, size = 0.2) +
        scale_color_brewer(palette = "Set1", na.value = "grey40")
    }
    
    print(p)
  }))
}


gender_imbalance_trend_plot <- function(input, IDB) {
  dataset <- reactive({
    IDB_by_Country <- IDB |> filter(Country == input$country_gender_imbalance) |> 
      select( Year, Country, Male.Population, Female.Population, Income) |>
      mutate(gender_ratio = Male.Population / Female.Population * 100)
  })
  
  return(renderPlot({
  
    p <-
      ggplot(dataset(), aes(x = Year, y = gender_ratio)) +
      geom_line() +
      labs(title = paste("Trend of gender ratio in", input$country_gender_imbalance, "(", unique(dataset()$Income) ,")"), x = "Year", y = "Male to Female %") +
      theme_minimal()
    
    print(p)
  }))
}
