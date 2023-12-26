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
      "Map Chart", fluid = T,
      sidebarLayout(position = "right",
                    sidebarPanel(
                      selectInput('d4', 'Choose a Variable:', names_map, names_map[[2]]),
                      sliderInput(
                        "mapYear",
                        "Map Year:",
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
      "Fertility Rate", fluid = T,
      sidebarLayout(position = "right",
                    sidebarPanel(
                      sliderInput(
                        "mapYearFertility",
                        "Map Year",
                        min = 2010,
                        max = 2023,
                        value = 2010,
                        step = 1,
                        sep = ",",
                        animate = TRUE
                      ),
                    ),
                    mainPanel(
                      plotOutput(outputId = "fertility_map")
                    )
      )
    ),
    tabPanel(
      "Infant Mortality Rate", fluid = T,
      sidebarLayout(position = "right",
                    sidebarPanel(
                      sliderInput(
                        "mapYearInfant",
                        "Map Year",
                        min = 2010,
                        max = 2023,
                        value = 2010,
                        step = 1,
                        sep = ",",
                        animate = TRUE
                      ),
                    ),
                    mainPanel(
                      plotOutput(outputId = "infant_map")
                    )
      )
    )
  )
)