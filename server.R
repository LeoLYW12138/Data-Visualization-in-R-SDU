if(!requireNamespace("shiny",quietly=TRUE))install.packages("shiny")
if(!requireNamespace("dplyr",quietly=TRUE))install.packages("dplyr")
if(!requireNamespace("ggplot2",quietly=TRUE))install.packages("ggplot2")
if(!requireNamespace("maps", quietly=TRUE))install.packages("maps")
if(!requireNamespace("RColorBrewer", quietly=TRUE))install.packages("RColorBrewer")


library(shiny)
library(dplyr)
library(tidyverse)
library(maps)
library(RColorBrewer)
library(moments)
library(scales)

source("./cost_of_living.R")
source("./shifts_income.R")
dff <- read.csv("./combined_new.csv", header = TRUE,sep = ',')


function(input, output) {
  
  
  
  output$tab5_plot <- cost_of_living(input, dff, output)
  output$tab6_plot <- shifts_income(input, dff, output)
    
   
  }
  
  
 