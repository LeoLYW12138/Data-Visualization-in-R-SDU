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
      "Tab 2", fluid = T,
      sidebarLayout(position = "right",
        sidebarPanel(
          selectInput('d4', 'D4', names_map[-(1:4)], names_map[[6]]),
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
          plotOutput(outputId = "gender_imbalance"),
          div(style = "display:flex; flex-direction: column; align-items: center; justify-content: center;",
          sliderInput(
            "year_gender_imbalance",
            label = div(style="text-align: center;", "Year:"),
            width = "80%",
            min = MIN_YEAR,
            max = MAX_YEAR,
            value = MIN_YEAR,
            step = 1,
            animate = TRUE
          ),
          checkboxInput("show_income_level_gender_imbalance", "Show Income level of the country", value=F),
              ),
    ),
    tabPanel(
      "Living cost vs Migration rate", fluid = T,
      sidebarLayout(position = "left",
                    sidebarPanel(
                      # selectInput("mode",
                      #             label="Mode",
                      #             c("By Year", "By Country")),
                      # sliderInput(
                      #   "year_migration_plot",
                      #   label = "Year:",
                      #   min = MIN_YEAR,
                      #   max = MAX_YEAR,
                      #   value = MIN_YEAR,
                      #   step = 1,
                      #   animate = TRUE
                      # ),
                      selectInput('country_migration_plot', "Country", c(unique(IDB$Country))),
                    ),
                    mainPanel(
                      imageOutput(outputId = "living_cost_migration"),
                    ),
      )
    )
  )
)