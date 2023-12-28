population_density <- function(input, df, output){
  return(
    renderPlot({
      
      df$LifeExp <- as.numeric(df$LifeExp)
      
      df <- df %>% filter(Year==input$year)
      
      if (input$region != 'All') {
        df <- df %>% filter(Continent==input$region)
      }
      
      ggplot(df, aes(x=.data[["Population.Density.(People.per.Sq..Km.)"]], y=LifeExp)) +
        geom_point(aes(color=Continent), size=2.75, alpha=0.75) + 
        ylim(min=40, max=max(df$LifeExp)) +
        scale_x_log10() +
        labs(title=paste("Year:", input$year),
             x="Population Density (people per sq.km)",
             y="Life Expectancy (years)",
             color="Continent") +
        theme(plot.title = element_text(size=15, hjust = 0.5),
              axis.title.x=element_text(size=12.5),
              axis.title.y=element_text(size=12.5),
              axis.text.x=element_text(size=10),
              axis.text.y=element_text(size=10),
              legend.position = "bottom",
              legend.title=element_text(size=12.5)) + 
        guides(color = guide_legend(nrow = 1)) + 
        geom_smooth(method=lm, color="red", se=FALSE)
    })
  )
}
  
  