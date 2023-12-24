living_cost_migration_plot <- function(input, IDB) {
  # a plot of living cost index against migration rate
  # it should show 
  # 1. all countries by year
  # 2. all year by country
  dataset <- reactive({
    IDB |> select(Year, Country, "Net.Migration.Rate") |>
      filter(Year == input$year_migration_plot & Name == input$name_migration_plot)
  })
  
  
  
  
  return(renderPlot({
    p <- ggplot(dataset(aes(x = "Net.Migration Rate"))) + 
      geom_point(alpha = 0.6) +
      scale_size(range = c(1,20))
  }))
}