## --- --------------------- ---
## Script name: Experimenten GIS data
## Author: Esmee Kramer
## Date Created: 09.11.2020
## --- --------------------- ---
## Notes:
##FS is interactiever dan WMS

##Wat de typename is, kun je onder de capabilities pagina vinden onder
##<FeatureTypeList>
##<FeatureType>
##<Name>ps-natura2000:ProtectedSite</Name>

## --- --------------------- ---


## 0. Libraries laden -----------------------------------------------------------------------
library(tidyverse)
library(leaflet)
library(sf)
library(httr)
library(tmap)
library(leaflet)
library(magrittr)
library(sf)

#st_simplify

#### 1. Make WFS Url  -----------------------------------------------------------------------

url <- parse_url("https://geodata.nationaalgeoregister.nl/natura2000/wfs")
url
xmin = "51.228183"
ymin = "4.057900"
xmax = "51.835593"
ymax = "5.491934"
BBOX = paste(xmin, ymin, xmax, ymax, sep=",")
url$query <- list(service = "WFS",
                  version = "2.0.0",
                  request = "GetFeature",
                  typename = "natura2000:natura2000",
                  BBOX = "51.228183,4.057900,51.835593,5.491934",
                  #BBOX = "93402, 346770, 892270, 589959",
                  #BBOX = BBOX,
                  srsName = "EPSG:4326",
                  outputFormat = "application/json")

request <- build_url(url)
# WFS_url <- paste0("http://geodata.nationaalgeoregister.nl/natura2000/wfs?",
#                   "&service=wfs&version=2.0.0&request=GetFeature",
#                   "&typeName=natura2000:natura2000",
#                   "&outputFormat=application/json",
#                   "&srsName=EPSG:4326")


#BBOX = Bounding Box. This parameter is a comma-separated list of four numbers that indicate the minimum and maximum 
#bounding coordinates of the feature instances that should be returned."
#Als de gegevens in EPSG:28992 (Amersfoort / RD New) geretourneerd worden, zoals bij de BAG standaard het geval is, 
#geldt bbox=xmin,ymin,xmax,ymax. 

# Als je de gegevens wilt opslaan in GeoJSON formaat, vergeet dan niet EPSG:4326 (WGS84) als coördinatenstelsel op te geven met behulp van de srsName parameter. 
# De meeste ontwikkelaars en data analisten verwachten namelijk dat coördinaten in een GeoJSON-bestand in WGS84 zijn.



#### 2. get WFS feature  -----------------------------------------------------------------------

# #Deze URL geven we als input aan de functie st_read() om de Simple feature collection nl_nationale_parken aan te maken. 
#(Een Simple feature collection is - kort gezegd - een R data frame met een geometrie kolom)
natura2000_wgs84 <- st_read(request)

#### 2A. Transform to WGS84  -----------------------------------------------------------------------

#natura2000_wgs84 <- st_transform(natura2000,4326)

#### 3. load data in leaflet  -----------------------------------------------------------------------

leaflet() %>% addTiles() %>%
  addPolygons(data = natura2000_wgs84,label = ~naam_n2k,popup = ~naam_n2k)

#### Shapefile gemeenten -----------------------------------------------------------------------
# ## Shapefile grenzen gemeenten
# gemeentenOMWB <-  c("OOSTERHOUT", "HEUSDEN", "LOON OP ZAND", "BERGEN OP ZOOM", "HILVARENBEEK", "ALPHEN-CHAAM" , 
#                     "BREDA","ALTENA", "WOENSDRECHT","ROOSENDAAL", "WAALWIJK", "TILBURG","DONGEN", "ETTEN-LEUR", "DRIMMELEN",
#                     "HALDERBERGE","MOERDIJK", "RUCPHEN", "OISTERWIJK","GOIRLE", "STEENBERGEN", "BAARLE-NASSAU", "GILZE EN RIJEN",
#                     "ZUNDERT","GEERTRUIDENBERG") 
# 
# wfs <- "https://geodata.nationaalgeoregister.nl/bestuurlijkegrenzen/wfs?request=GetFeature&service=WFS&version=1.1.0&typeName=bestuurlijkegrenzen:gemeenten&outputFormat=application%2Fjson" 
# gemeenten <- st_read(wfs)
# gemeenten <- st_transform(gemeenten, CRS('+proj=longlat +datum=WGS84 +no_defs'))
# #unique(gemeenten$gemeentenaam)
# 
# gemeenten_subset <- gemeenten %>% 
#   select(gemeentenaam, geometry) %>% 
#   mutate(gemeentenaam = toupper(gemeentenaam)) %>% 
#   filter(gemeentenaam %in% gemeentenOMWB) 
# 
# gevonden <- unique(gemeenten_subset$gemeentenaam); length(gevonden) == 25
# gemeenten <- gemeenten_subset #%>% mutate(gemeentenaam = toTitleCase(tolower(gemeentenaam)))
# 
# 
# 
# leaflet() %>%
#   addTiles() %>% 
#   addProviderTiles("Esri.WorldImagery") %>% 
#   
#   addPolygons(data = gemeenten,
#               color = "#444444", weight = 1, smoothFactor = 0.5, opacity = 1.0,
#               #fillColor = ~colorpal(gemeentena), fillOpacity = 0.5,
#               highlightOptions = highlightOptions(color = "white", weight = 2, bringToFront = TRUE)) %>%
#   
#   #addSearchOSM() %>% 
#   addResetMapButton()

