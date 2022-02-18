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

#https://docs.microsoft.com/en-us/rest/api/maps/search/getsearchaddress

key = "XI_tNqkJNEp4SrChlahsFYTYWsHHmw8b7dnq0s9EjZ8"
query = "Fortgracht 15, Sleeuwijk, 4254VE"

url = paste0('https://atlas.microsoft.com/search/address/json?api-version=1.0&subscription-key=', key, '&query=', query, sep="")
             
res <- HttpClient$new(
  url = url,
  auth = none)
x <- res$get()
output <- jsonlite::fromJSON(x$parse("UTF-8"))
summary <- output$summary %>% unlist() %>% as.data.frame() %>% t() %>% as.data.frame()
results <- output$results
PC <- results$address$extendedPostalCode

## In een for loop ziet het er als volgt uit;
subset <- data %>% mutate(regelnummer = seq(1, length(subset$Adres)))

#lege tabel maken waar elke uitkomst naartoe geschreven wordt
empty <- data.frame(matrix(ncol=17, nrow=0)) %>% as.data.frame(row.names=NULL)
kolomnamen <- c("type","id","score","streetNumber","streetName", "municipality","countrySubdivision", "postalCode",
                "extendedPostalCode", "countryCode", "country", "countryCodeISO3" ,"freeformAddress" ,"localName","lat",
                "lon", "regelnummer")
colnames(empty) <- kolomnamen

#loopen over de tabel, trycatch eromheen zorgt ervoor dat hij niet stopt bij eventuele fouten
for (i in 1:nrow(subset)){
  tryCatch({
    
    #basisquery voor Azure Maps API
    key = "XI_tNqkJNEp4SrChlahsFYTYWsHHmw8b7dnq0s9EjZ8"
    query = subset$Adres[i]
    url = paste0('https://atlas.microsoft.com/search/address/json?api-version=1.0&subscription-key=', key, '&query=', query, sep="")
    
    res <- HttpClient$new(
      url = url,
      auth = none)
    x <- res$get()
    output <- jsonlite::fromJSON(x$parse("UTF-8"))
    summary <- output$summary %>% unlist() %>% as.data.frame() %>% t() %>% as.data.frame()
    results <- output$results 
    PC <- results$address$extendedPostalCode
    subset$PC[i] <- PC

  }, error=function(e){} )}

rm(x,res, results_A, results_B, results_C)





