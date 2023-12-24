library(shiny)
library(ggplot2)
library(readr)
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
      "Gender Imbalance", fluid = T,
      sidebarLayout(position = "right",
        sidebarPanel(
          sliderInput(
            "year1",
            label = "Year:",
            min = MIN_YEAR,
            max = MAX_YEAR,
            value = MIN_YEAR,
            step = 1,
            animate = TRUE
          ),
        ),
        mainPanel(
          plotOutput(outputId = "gender_imbalance")
        )
      )
    ),
    tabPanel(
      "Living cost vs Migration rate", fluid = T,
      sidebarLayout(position = "left",
                    sidebarPanel(
                      selectInput("mode",
                                  label="Mode",
                                  c("By Year", "By Country")),
                      sliderInput(
                        "year_migration_plot",
                        label = "Year:",
                        min = MIN_YEAR,
                        max = MAX_YEAR,
                        value = MIN_YEAR,
                        step = 1,
                        animate = TRUE
                      ),
                      selectInput('name_migration_plot', "Country", c(unique(IDB$Name))),
                    ),
                    mainPanel(
                      plotOutput(outputId = "living_cost_migration")
                    )
      )
    )
  )
)