library(readr)
library(tidyverse)

#' Load the IDB dataset from csv to an n-d array with dimensions: year, country, indicators
load_IDB <- function () {
  headers <- read_csv("./IDB.csv", n_max=0, show_col_types = FALSE)
  
  formatted_names <- str_replace_all(names(headers), c(" " = "." , "," = "" ))
  name2colname_map <- list()
  colname2name_map <- list()
  for (i in 1:length(formatted_names)) {
    name2colname_map[names(headers)[i]] <- formatted_names[i]
    colname2name_map[formatted_names[i]] <- names(headers)[i]
  }
  IDB <- read_csv("./IDB.csv", col_names = FALSE, skip = 1, show_col_types = FALSE)
  names(IDB) <- formatted_names

  # remove useless rows e.g. --> 2010
  IDB <- IDB |> filter(!startsWith(Name, "->"))
  # convert all "XXX,XXX.XX" formatted values to number
  IDB[, -(1:4)] <- IDB[, -(1:4)] |> lapply(function(x) parse_guess(x, na=c("", "--", "NA"), guess_integer = TRUE))
  IDB <- IDB |> mutate_at(c("Year"), as.integer)
  # TODO group by year and country
  
  attr(IDB, "name2colname_map") <- name2colname_map
  attr(IDB, "colname2name_map") <- colname2name_map
  return (IDB)
  # return( c(IDB, names_map) )
}


load_WorldMap <- function (){
  world_data <- map_data("world")
  
  #Make the world map data regions match the data from IDB for country names
  world_data <- world_data %>% mutate(region = str_replace(region, "USA", "United States"))
  world_data <- world_data %>% mutate(region = str_replace(region, "UK", "United Kingdom"))
  world_data <- world_data %>% mutate(region = str_replace(region, "Democratic Republic of the Congo", "Congo (Brazzaville)"))
  world_data <- world_data %>% mutate(region = str_replace(region, "Republic of Congo", "Congo (Kinshasa)"))
  world_data <- world_data %>% mutate(region = str_replace(region, "South Korea", "Korea, South"))
  world_data <- world_data %>% mutate(region = str_replace(region, "North Korea", "Korea, North"))
  world_data <- world_data %>% mutate(region = str_replace(region, "Myanmar", "Burma"))
  world_data <- world_data %>% mutate(region = str_replace(region, "Ivory Coast", "Côte d'Ivoire"))
  
  return(world_data)
}
