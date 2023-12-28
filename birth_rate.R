birth_rate <- function(input, df, output){
  return(
    output$line <- renderPlot({
      
      df$Crude.Birth.Rate <- as.numeric(df$Crude.Birth.Rate)
      
      df2 <- df %>% filter(Year==2022)
      df2 <- df2 %>% select(Country, Income)
      df2 <- df2 %>% rename(Income_t=Income)
      
      df3 <- merge(df, df2, by="Country")
      
      df3 <- df3 %>% 
        filter(Continent == input$region, Income_t == input$group)
      
      ggplot(df3, aes(x=Year, y=Crude.Birth.Rate)) + 
        geom_line(aes(color=Country)) + 
        geom_point(aes(color=Country, shape=Income), size=1.5, alpha=0.75) +
        labs(title=paste(input$region),
             x="Year", y="Birth Rate",
             color="Country", shape="Income Group") +
        theme(plot.title = element_text(size=15, hjust = 0.5),
              axis.title.x=element_text(size=12.5),
              axis.title.y=element_text(size=12.5),
              axis.text.x=element_text(size=10),
              axis.text.y=element_text(size=10),
              legend.title=element_text(size=12.5))
    })
  )
}