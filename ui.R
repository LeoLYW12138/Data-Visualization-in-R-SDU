library(shiny)
library(ggplot2)
library(readr)
source("./preprocess.R")

IDB <- load_IDB()
names_map <- attr(IDB, "name2colname_map")[-c(1:4)]

fluidPage(
  
  titlePanel("DV 16"),
  
  sidebarLayout(position="right",
    sidebarPanel(
      selectInput('d1', 'D1', names_map),
      selectInput('d2', 'D2', names_map, names_map[[2]]),
      selectInput('name', "Country", c(unique(IDB$Name))),
      sliderInput("year", "Year",
                  min = 2010, max = 2023, value = c(2010, 2023)),
      
      # selectInput('color', 'Color', c('None', names(dataset))),
      # 
      # checkboxInput('jitter', 'Jitter'),
      # checkboxInput('smooth', 'Smooth'),
      # 
      # selectInput('facet_row', 'Facet Row', c(None='.', names(dataset))),
      # selectInput('facet_col', 'Facet Column', c(None='.', names(dataset)))
    ),
    
    mainPanel(
      plotOutput('plot'),
      tableOutput('table')
    )
  )
  
)