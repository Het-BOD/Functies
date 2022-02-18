library(tidyverse)
library(igraph)
library(readxl)



setwd('~/GitHub')
# setwd("~/GitHub/Afval/Data voor brabant Breed/Data")



data <- read_excel("Afval/Afval/Data voor brabant Breed/Data/LMA_ODBN.xlsx")



data_set <- data %>%
  select(`Ontdoener Bedrijfsnummer`, `Ontvanger Bedrijfsnummer`)



namen <- data %>%
  select(`Ontdoener Bedrijfsnummer`, `Ontdoener Naam`)



bedrijven <- data %>%
  select(`Ontdoener Bedrijfsnummer`, `Ontvanger Bedrijfsnummer`) %>%
  left_join(namen) %>%
  left_join(namen, by = c("Ontvanger Bedrijfsnummer" = "Ontdoener Bedrijfsnummer")) %>%
  unique() %>%
  rename(Ontdoener = 'Ontdoener Naam.x', Ontvanger = 'Ontdoener Naam.y')



bedrijven1 <- bedrijven %>%
  select(Ontdoener, Ontvanger)



bedrijven$Ontvanger[is.na(bedrijven$Ontvanger)] <- "Onbekend"




data_Gevuld <- bedrijven1 %>% unique() %>%
  filter(!is.na(Ontvanger),
         Ontdoener %in% Ontvanger) %>% unique()



bedrijven.mat <- as.matrix(data_Gevuld)



# g1 <- graph_from_data_frame(bedrijven1, directed = FALSE)



g <- graph.edgelist(bedrijven.mat, directed = TRUE)



as_edgelist(g)



plot(g)



### Overige dingen
# g <- set_vertex_attr(g, "gender", value = genders)
g <- set_vertex_attr(g, "gender", value = genders)



# Create new vertex attribute called 'age'
g <- set_vertex_attr(g, "age", value = ages)



# View all vertex attributes in a list
vertex_attr(g)






### DATACAMP
# # Load igraph
# library(igraph)
#
# # Inspect the first few rows of the dataframe 'friends'
# head(friends)
#
# # Convert friends dataframe to a matrix
# friends.mat <- as.matrix(friends)
#
# # Convert friends matrix to an igraph object
# g <- graph.edgelist(friends.mat, directed = FALSE)
#
#
# # Make a very basic plot of the network
# plot(g)