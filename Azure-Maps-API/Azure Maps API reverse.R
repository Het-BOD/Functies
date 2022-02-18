## --- --------------------- ---
## Script name: Geocoding with Azure Maps API
## Author: Esmee Kramer
## Date Created: 05.10.2020
## --- --------------------- ---
## Notes:


## Libraries laden -----------------------------------------------------------------------
library(tidyverse)
library(httr)
library(jsonlite)
library(crul)

## Geocoding with Azure Maps API  -----------------------------------------------------------------------
#Geocoding is the process of converting addresses (like a street address) into geographic coordinates (latitude and longitude), 
#which you can use to place markers on a map, or position the map.

data <- read_excel("~\\GitHub\\IR\\IR - Mestsilo's\\Fase1_Data_preparation\\Oud\\RVO\\Mestopslagen Provincie Noord-Brabant 23-06-2021.xlsx") %>% 
  mutate(coords = paste(BREEDTEGRAAD, LENGTEGRAAD, sep=", ")) %>% 
  mutate(straatnaam = NA, woonplaats = NA, huisnummer = NA, gemeente = NA, postcode = NA, adres= NA)


#https://docs.microsoft.com/en-us/rest/api/maps/search/getsearchaddress

key = "XI_tNqkJNEp4SrChlahsFYTYWsHHmw8b7dnq0s9EjZ8"
query = "51.49639140199705, 6.156977356544664"
query=data$coords[358]

url = paste0('https://atlas.microsoft.com/search/address/reverse/json?api-version=1.0&subscription-key=', key, '&query=', query, sep="")

res <- HttpClient$new(
  url = url,
  auth = none)
x <- res$get()
output <- jsonlite::fromJSON(x$parse("UTF-8"))
summary <- output$summary %>% unlist() %>% as.data.frame() %>% t() %>% as.data.frame()
results <- output$addresses
straatnaam <- results$address$streetName
huisnummer <- results$address$streetNumber
postcode <- results$address$extendedPostalCode
woonplaats <- results$address$municipalitySubdivision
gemeente <- results$address$municipality


## In een for loop ziet het er als volgt uit;
#Zorgen dat coordinaten in geografische format staan (zie R-bestand Omzetten coordinaten)
data <- read.csv("bestand.csv") #bestandsnaam wijzigen
subset <- data %>% mutate(regelnummer = seq(1, length(data$X))) #Regelnummer aanmaken #kolomnaam X wijzigen
subset$coordinaten <- paste0(subset$long, ", ", subset$lat) #zorgen dat coordinaten als string in 1 kolom komen te staan

#lege tabel maken waar elke uitkomst naartoe geschreven wordt
empty <- data.frame(matrix(ncol=17, nrow=0)) %>% as.data.frame(row.names=NULL)
kolomnamen <- c("type","id","score","streetNumber","streetName", "municipality","countrySubdivision", "postalCode",
                "extendedPostalCode", "countryCode", "country", "countryCodeISO3" ,"freeformAddress" ,"localName","lat",
                "lon", "regelnummer")
colnames(empty) <- kolomnamen

#loopen over de tabel, trycatch eromheen zorgt ervoor dat hij niet stopt bij eventuele fouten
for (i in 1:nrow(data)){
 # i=9

    #basisquery voor Azure Maps API
    key = "XI_tNqkJNEp4SrChlahsFYTYWsHHmw8b7dnq0s9EjZ8"
    query = data$coords[i]
    url = paste0('https://atlas.microsoft.com/search/address/reverse/json?api-version=1.0&subscription-key=', key, '&query=', query, sep="")
    
    res <- HttpClient$new(
      url = url,
      auth = none)
    x <- res$get()
    output <- jsonlite::fromJSON(x$parse("UTF-8"))
    summary <- output$summary %>% unlist() %>% as.data.frame() %>% t() %>% as.data.frame()
    results <- output$addresses 
    # straatnaam <- results$address$streetName
    # huisnummer <- results$address$streetNumber
    # postcode <- if(!is_empty(results$address$extendedPostalCode)) { results$address$extendedPostalCode} else{ results$address$postalCode}
    # woonplaats <- results$address$municipalitySubdivision
    # gemeente <- results$address$municipality
    # adres <- results$address$freeformAddress

    try(data$straatnaam[i] <- results$address$streetName)
    try(data$huisnummer[i] <- results$address$streetNumber)
    data$postcode[i] <- if(!is_empty(results$address$extendedPostalCode)) { results$address$extendedPostalCode } else { results$address$postalCode}
    data$woonplaats[i] <- if(!is_empty(results$address$municipalitySubdivision)) {results$address$municipalitySubdivision} else {results$address$municipality}
    data$gemeente[i] <- results$address$municipality
    data$adres[i] <- results$address$freeformAddress
    
    print(i)
  }

rm(x,res, results_A, results_B, results_C)

library(xlsx)
write.xlsx(data, "data_incl_coords.xlsx")




