# Library -----------------------------------------------------------------
    if(require("conflicted") == FALSE){
install.packages("conflicted"); library("conflicted")}
    if(require("tidyverse") == FALSE){
install.packages("tidyverse"); library("tidyverse")}
    if(require("data.table") == FALSE){
install.packages("data.table"); library("data.table")}
    if(require("janitor") == FALSE){
install.packages("janitor"); library("janitor")}

# Resolve conflicts -------------------------------------------------------


conflict_prefer("select", "dplyr")
conflict_prefer("filter", "dplyr")



