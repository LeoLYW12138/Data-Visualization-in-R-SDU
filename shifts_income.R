shifts_income <- function(input, dff, output) {
  
  # Filter data based on the selected year
  dff <- dff %>%
    mutate(Year = as.integer(Year),
           Rent.Index = as.numeric(Rent.Index),
           Groceries.Index = as.numeric(Groceries.Index),
           LifeExp = as.numeric(LifeExp),
           Area.in.Square.Kilometers = as.numeric(Area.in.Square.Kilometers),
           Population = as.integer(Population),
           Annual.Growth.Rate.. = as.numeric(dff[["Annual.Growth.Rate.%"]]),
           Rate.of.Natural.Increase = as.numeric(Rate.of.Natural.Increase),
           Population.Density..People.per.Sq..Km.. = as.numeric(dff[["Population.Density.(People.per.Sq..Km.)"]]),
           Natural.Increase = as.numeric(Natural.Increase),
           Total.Fertility.Rate = as.numeric(Total.Fertility.Rate),
           Crude.Birth.Rate = as.numeric(Crude.Birth.Rate),
           Gross.Reproduction.Rate = as.numeric(Gross.Reproduction.Rate),
           Infant.Mortality.Rate..Both.Sexes = as.numeric(Infant.Mortality.Rate.Both.Sexes),
           Crude.Death.Rate = as.numeric(Crude.Death.Rate),
           Deaths..both.sexes = as.numeric(Deaths.both.sexes),
           Net.Migration.Rate = as.numeric(Net.Migration.Rate),
           Net.international.migrants..both.sexes = as.numeric(Net.international.migrants.both.sexes),
           Cost.of.Living.Index = as.numeric(Cost.of.Living.Index),
           Cost.of.Living.Plus.Rent.Index = as.numeric(Cost.of.Living.Plus.Rent.Index),
           Groceries.Index = as.numeric(Groceries.Index),
           Restaurant.Price.Index = as.numeric(Restaurant.Price.Index),
           Local.Purchasing.Power.Index = as.numeric(Local.Purchasing.Power.Index))
  
  d <- dff %>% 
    group_by(Country) %>%
    summarise(UniqueIncome = n_distinct(Income)) %>%
    filter(UniqueIncome >= 2)
  
  #e <- dff %>% 
  
  selected_countries_d <- d$Country
  # selected_countries_e <- e$Country
  dff_filtered <- dff %>%
    filter(Country %in% selected_countries_d 
           #& Country %in% selected_countries_e
    ) %>%
    mutate(Year = as.numeric(Year))
  
  
  # Filter data based on the selected continent
  filtered_data <- reactive({
    filtered <- dff_filtered %>%
      filter(Continent %in% input$continent) %>%
      arrange(Year)
    # Ensure that 'Year' is treated as a numeric variable for sorting
    filtered$Year <- as.numeric(filtered$Year)
    filtered
  })
  
  
  # Generate the scatter plot
  return(renderPlot({
    # print(filtered_data())  # Print the filtered data for debugging
    
    ggplot(data = filtered_data(), aes(x = factor(Year, levels = unique(Year)), y = get(input$yaxis), group = Country, color = Country, shape = Income)) +
      geom_line(linetype = "solid") + 
      geom_point(size = 3) +
      labs(x = "Year", y = input$yaxis, color = "Country") 
    
  }))
}
    