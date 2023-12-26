living_cost_migration_plot <- function(input, IDB, output) {
  # a plot of living cost index against migration rate
  # it should show 
  # 1. all countries by year
  # 2. all year by country
  # do a time series plot by country first
  dataset <- reactive({
    IDB |> select(Year, Country, "Net.Migration.Rate") |>
      filter(Country == input$country_migration_plot)
  })
  
  output$debug <- renderTable(dataset())
  
  
  return(renderImage({
    outfile <- tempfile(fileext='.gif')
  
    p <- ggplot(dataset(), aes(x = Year, group=1)) + 
      geom_point(aes(y = .data[["Net.Migration.Rate"]])) +
      geom_line(aes(y = .data[["Net.Migration.Rate"]])) +
      geom_text(aes(y = .data[["Net.Migration.Rate"]], label=.data[["Net.Migration.Rate"]]),vjust=-0.25) +
      transition_reveal(Year) +
      xlab("Year")
    
    anim_save("outfile.gif", animate(p))
    list(src = "outfile.gif",
         contentType = "image/gif")
  
  }, deleteFile = TRUE))
}