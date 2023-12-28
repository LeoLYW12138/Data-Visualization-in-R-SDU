library(shiny)
library(ggplot2)
library(readr)
source("./preprocess.R")

IDB <- load_IDB()
LIVING_COST_DB <- load_living_cost()
names_map <- attr(IDB, "name2colname_map")[-c(1:4)]

fluidPage(titlePanel("DV 16"),
          tabsetPanel(
            tabPanel(
              "Fertility Rate",
              fluid = T,
              sidebarLayout(
                position = "right",
                sidebarPanel(
                  sliderInput(
                    "mapYearFertility",
                    "Map Year:",
                    min = 2010,
                    max = 2023,
                    value = 2011,
                    step = 2,
                    sep = "",
                    animate = TRUE
                  ),
                ),
                mainPanel(plotOutput(outputId = "fertility_map"))
              )
            ),
            tabPanel(
              "Infant Mortality Rate",
              fluid = T,
              sidebarLayout(
                position = "right",
                sidebarPanel(
                  sliderInput(
                    "mapYearInfant",
                    "Map Year:",
                    min = 2010,
                    max = 2023,
                    value = 2010,
                    step = 1,
                    sep = "",
                    animate = TRUE
                  ),
                ),
                mainPanel(plotOutput(outputId = "infant_map"))
              )
            ),
            tabPanel(
              "Gender Ratio",
              fluid = T,
              plotOutput(outputId = "gender_imbalance"),
              div(
                style = "display:flex; flex-direction: column; align-items: center; justify-content: center;",
                div(
                  style = "margin-right: auto; padding-left:10%;",
                  checkboxInput(
                    "show_income_level_gender_imbalance",
                    "Show Income level of the country",
                    value = F
                  ),
                ),
                  sliderInput(
                    "year_gender_imbalance",
                    label = div(style = "text-align: center;", "Year:"),
                    width = "80%",
                    min = MIN_YEAR,
                    max = MAX_YEAR,
                    value = MIN_YEAR,
                    step = 1,
                    animate = TRUE
                  ),
              ),
              sidebarLayout(
                position = "left",
                sidebarPanel(selectInput(
                  "country_gender_imbalance",
                  "Country",
                  c(unique(IDB$Country))
                )),
                mainPanel(plotOutput(outputId = "gender_trend"))
              ),
              div(style= "height: 200px;")
            ),
            tabPanel(
              "Living cost vs Migration rate",
              fluid = T,
              sidebarLayout(
                position = "left",
                sidebarPanel(# selectInput("mode",
                  #             label="Mode",
                  #             c("By Year", "By Country")),
                  selectInput(
                    'country_migration_plot', "Country", c(unique(LIVING_COST_DB$Country))
                  ), ),
                mainPanel(imageOutput(outputId = "living_cost_migration"), ),
                # mainPanel(plotOutput(outputId = "living_cost_migration"),)
              )
            ),
            # tabPanel(
            #   "Map Chart",
            #   fluid = T,
            #   sidebarLayout(position = "right",
            #                 sidebarPanel(
            #                   selectInput('d4', 'Choose a Variable:', names_map, names_map[[2]]),
            #                   sliderInput(
            #                     "mapYear",
            #                     "Map Year:",
            #                     min = 2010,
            #                     max = 2023,
            #                     value = 2010,
            #                     step = 1,
            #                     sep = "",
            #                     animate = TRUE
            #                   ),
            #                 ), )
            # ),
          ),
)
