living_cost_migration_plot <- function(input, IDB, LIVING_COST_DB) {
  # a plot of living cost index against migration rate
  # it should show
  # 1. all countries by year
  # 2. all year by country
  # do a time series plot by country first
  dataset <- reactive({
    filteredMigration <-
      IDB |> select(
        Year,
        Country,
        Income,
        "Net.Migration.Rate",
        "Net.international.migrants.both.sexes",
        "Population"
      ) |>
      filter(Country == input$country_migration_plot)
    
    filteredLivingCost <-
      LIVING_COST_DB |> select(Year, Country, "Cost.of.Living.Plus.Rent.Index") |>
      filter(Country == input$country_migration_plot)
    
    data <-
      left_join(
        filteredLivingCost,
        filteredMigration,
        by = c("Country" = "Country", "Year" = "Year")
      )
  })
  
  # pieChartData <- reactive({
  #   p <- data.frame(
  #     group = dataset()$Year,
  #     migrants = dataset()$Net.international.migrants.both.sexes,
  #     domestics = dataset()$Population - dataset()$Net.international.migrants.both.sexes
  #   )
  # })
  
  return(renderImage({
    outfile <- tempfile(fileext = '.gif')
    
    p <-
      ggplot(
        dataset(),
        aes(x = Net.Migration.Rate, y = Cost.of.Living.Plus.Rent.Index, group = 1)
      ) +
      # geom_bar(pieChartData(), aes(x = "", y = values, fill = group ), stat = "identity") +
      geom_point(aes(size = 3), show.legend = F) +
      geom_text(aes(label = trunc(Year)), vjust = -1) +
      
      transition_states(
        Year,
        transition_length = 1,
        state_length = 3,
        wrap = FALSE
      ) +
      shadow_mark(alpha = 0.7, size = 3) +
      enter_grow() +
      enter_fade() +
      labs(
        title = "Living Cost against Migration Rate",
        subtitle = paste(
          input$country_migration_plot,
          "(",
          dataset()$Income,
          ")"
        ),
        x = "Net Migration Rate",
        y = "Cost of Living Index",
        caption = "Year: {closest_state}"
      )
    
    anim_save("outfile.gif", animate(p, fps = 5, renderer = gifski_renderer(loop = FALSE)))
    list(src = "outfile.gif",
         contentType = "image/gif")
    
  }, deleteFile = TRUE))
}