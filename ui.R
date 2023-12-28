library(shiny)
library(ggplot2)
library(readr)
source("./preprocess.R")

IDB <- load_IDB()
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
              "Gender Imbalance",
              fluid = T,
              plotOutput(outputId = "gender_imbalance"),
              div(
                style = "display:flex; flex-direction: column; align-items: center; justify-content: center;",
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
                checkboxInput(
                  "show_income_level_gender_imbalance",
                  "Show Income level of the country",
                  value = F
                ),
              ),
            ),
            tabPanel(
              "Living cost vs Migration rate",
              fluid = T,
              sidebarLayout(
                position = "left",
                sidebarPanel(# selectInput("mode",
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
                  selectInput(
                    'country_migration_plot', "Country", c(unique(IDB$Country))
                  ),),
                mainPanel(imageOutput(outputId = "living_cost_migration"),),
              )
            ),
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
      "Do countries in the same income range and continent share similar groceries and renting index?", fluid = T,
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
      "Are there any changes in each variable when a country shifts from one income group to another?", fluid = T,
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
          ),)
