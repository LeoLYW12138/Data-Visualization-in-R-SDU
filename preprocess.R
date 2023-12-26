if(!requireNamespace("maps", quietly=TRUE))install.packages("maps")
library(readr)
library(tidyverse)
library(maps)

MIN_YEAR=2010
MAX_YEAR=2023

#' Load the IDB dataset from csv to an n-d array with dimensions: year, country, indicators
load_IDB <- function () {
  headers <- read_csv("./IDB_combined.csv", n_max=0, show_col_types = FALSE)
  
  formatted_names <- str_replace_all(names(headers), c(" " = "." , "," = "" ))
  name2colname_map <- list()
  colname2name_map <- list()
  for (i in 1:length(formatted_names)) {
    name2colname_map[names(headers)[i]] <- formatted_names[i]
    colname2name_map[formatted_names[i]] <- names(headers)[i]
  }
  IDB <- read_csv("./IDB_combined.csv", col_names = FALSE, skip = 1, show_col_types = FALSE)
  names(IDB) <- formatted_names

  # remove useless rows e.g. --> 2010
  IDB <- IDB |> filter(!startsWith(Country, "->"))
  # convert all "XXX,XXX.XX" formatted values to number
  # IDB[, -(1:7)] <- IDB[, -(1:7)] |> lapply(function(x) ifelse(is.character, parse_guess(x, na=c("", "--", "NA"), guess_integer = TRUE), x))
  IDB <- IDB |> mutate_at(c("Year"), as.integer)
  # TODO group by year and country
  
  attr(IDB, "name2colname_map") <- name2colname_map
  attr(IDB, "colname2name_map") <- colname2name_map
  return (IDB)
  # return( c(IDB, names_map) )
}


load_WorldMap <- function (){
  world_data <- map_data("world") |>
    mutate(region = str_replace_all(region, c("USA" = "United States",
                                              "UK" = "United Kingdom",
                                              "Democratic Republic of the Congo" = "Congo (Brazzaville)",
                                              "Republic of Congo" = "Congo (Kinshasa)",
                                              "South Korea" = "Korea, South",
                                              "North Korea" = "Korea, North",
                                              "Myanmar" = "Burma",
                                              "Ivory Coast" = "Côte d'Ivoire")))

  return(world_data)
}
