library(shiny)
library(ggplot2)
library(readr)
library(plotly)
source("./preprocess.R")

IDB <- load_IDB()
COMBINED_DB <- load_combined()
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
                ),
                # selectInput(inputId="income_gender_imbalance", label="Income Level",
                #             choices = c(
                #               "Low income",
                #               "Lower middle income",
                #               "Upper middle income",
                #               "High income"),
                #             selected = "Low Income")
                ),
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
                    'country_migration_plot', "Country", c(unique(COMBINED_DB$Country))
                  ),
                p("Notice: It takes some time for gganimate to render the animated graph")
                ),
                mainPanel(imageOutput(outputId = "living_cost_migration"), ),
                # mainPanel(plotOutput(outputId = "living_cost_migration"),)
              )
            ),
            tabPanel(
              "Do countries in the same income range and continent share similar groceries and renting index?", fluid = T,
              sidebarLayout(
                sidebarPanel(
                  selectInput("year", "Select Year", choices = unique(COMBINED_DB$Year), selected = min(COMBINED_DB$Year)),
                  selectInput("continent", "Select Continent", choices = unique(COMBINED_DB$Continent), multiple = TRUE, selected = "Asia")
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
                  selectInput("continent", "Select Continent", choices = unique(COMBINED_DB$Continent), multiple = TRUE, selected = "Asia"),
                  selectInput("yaxis", "Select Y-axis", choices = names(COMBINED_DB), selected = names(COMBINED_DB)[1])
                ),
                mainPanel(
                  plotOutput("tab6_plot")
                )
              )
            ),
            tabPanel("Relationship Between Population Density and Life Expectancy",
              fluid = T,
              sidebarLayout(
                
                sidebarPanel(
                  sliderInput(inputId="year", label="Select Year",
                              min=2010, max=2022, value=2010
                  ),
                  selectInput(inputId="region", label="Select Continent",
                              choices=c("All", "Africa", "Asia", "Europe", 
                                        "North America", "Oceania", "South America"),
                              selected = "All")
                ),
                
                mainPanel(
                  plotOutput(outputId="tab7_plot")
                )
              )
            ),
            tabPanel(
              "Birth Rate Trend from 2010 to 2022",
              fluid = T,
              sidebarLayout(
                sidebarPanel(
                  selectInput(inputId="region_birth_rate", label="Select Continent",
                              choices=c("Africa", "Asia", "Europe", "North America", 
                                        "Oceania", "South America"),
                              selected = "Europe"),
                  
                  selectInput(inputId="group_birth_rate", label="Select Income Range",
                              choices = c(
                                "Low" = "L",
                                "Lower Middle" = "LM",
                                "Upper Middle" = "UM",
                                "High" = "H"),
                              selected = "UM")
                ),
                
                mainPanel(
                  plotOutput(outputId="tab8_plot")
                )
              )
            ),
            tabPanel(
              "Download PDF",
              fluid = T,
              sidebarLayout(
                position = "left",
                tags$a("View the report in the browser", href="Report-1.pdf"),
                mainPanel(downloadButton("downloadData", "Download Report"),),
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
