library(shiny)
library(ggplot2)
library(readr)
library(leaflet.extras)
source("./preprocess.R")

IDB <- load_IDB()
names_map <- attr(IDB, "name2colname_map")[-c(1:4)]

fluidPage(
  titlePanel("DV 16"),
  tabsetPanel(
    tabPanel(
      "Tab 1", fluid = T,
      sidebarLayout(position = "right",
        sidebarPanel(
          selectInput('d1', 'D1', names_map),
          selectInput('d2', 'D2', names_map, names_map[[2]]),
          selectInput('name', "Country", c(unique(IDB$Name))),
          sliderInput(
            "year",
            "Year",
            min = 2010,
            max = 2023,
            value = c(2010, 2023)
          ),
        ),
        mainPanel(
          plotOutput('tab1_plot'),
          tableOutput('table')
        )
      )
    ),
    tabPanel(
      "Tab 2", fluid = T,
      #plotOutput(outputId = "map"),
      sidebarLayout(position = "right",
                    sidebarPanel(
                      selectInput('d4', 'D4', names_map, names_map[[2]]),
                      sliderInput(
                        "mapYear",
                        "MapYear:",
                        min = 2010,
                        max = 2023,
                        value = 2010,
                        step = 1,
                        sep = ",",
                        animate = TRUE
                      ),
                    ),
                    mainPanel(
                      plotOutput(outputId = "map")
                    )
      )
    ),
    tabPanel(
      "Grocery and Renting Index", fluid = T,
      sidebarLayout(
        sidebarPanel(
          selectInput("year", "Select Year", choices = unique(dff$Year), selected = min(dff$Year)),
          selectInput("continent", "Select Continent", choices = unique(dff$Continent), multiple = TRUE, selected = "Asia")
        ),
        mainPanel(
          plotlyOutput("tab5_plot")
        )
      )
    ),
    tabPanel(
      "Grocery and Renting Index", fluid = T,
      sidebarLayout(
        sidebarPanel(
          selectInput("continent", "Select Continent", choices = unique(dff$Continent), multiple = TRUE, selected = "Asia"),
          selectInput("yaxis", "Select Y-axis", choices = names(dff), selected = names(dff)[1])
        ),
        mainPanel(
          plotOutput("tab6_plot")
        )
      )
    )
    
  )
)