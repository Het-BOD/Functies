## --- --------------------- ---
## Script name: Algemeen script voor het omzetten van coordinaten
## Author: Esmee Kramer
## Date Created: 06.10.2020
## --- --------------------- ---
## Notes:
## Verschillende coordinatenstelsels:
## PDOK gebruikt EPSG:28992 oftewel Rijksdriehoeksstelsel
## Azure MAPS API gebruikt lat & lon

## Amersfoort / RD New heeft EPSG code 28992    RD = RijksDriehoeksstelsel
## Pseudo-Mercator heeft EPSG code 3857         heeft meter (m) als eenheid
## WGS84 heeft EPSG code 4326                   gebruikt door oa GoogleMaps, long & lat

## Lat = Y
## Lon = X

##https://mgimond.github.io/Spatial/coordinate-systems-in-r.html

#NOG VOORBEELDWAARDEN TOEVOEGEN!

## Libraries laden -----------------------------------------------------------------------
library(rgdal)

## Voorbeeldscripts -----------------------------------------------------------------------

#Van rijksdriehoeksstelsel (EPSG code 28992) naar Pseudo-Mercator (EPSG code 4326)

coordinates(data) <- c("X", "Y")
proj4string(data) <- CRS("+init=EPSG:28992") #je huidige stelsel
CRS.new <- CRS("+init=epsg:4326") #het gewenste stelsel
data <- spTransform(data, CRS.new) %>%  as.data.frame() #%>% rename(lon_deg=X, lat_deg=Y)




