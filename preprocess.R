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
