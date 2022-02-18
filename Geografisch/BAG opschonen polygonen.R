## --- --------------------- ---
## Script name: BAG data opschonen polygonen
## Author: Esmee Kramer
## Date Created: 08.02.2021
## --- --------------------- ---


#### 0. Set-up -----------------------------------------------------------------------
#Libraries
library(tidyverse)
library(readxl)
library(RODBC)
library(getPass)

#Functies
lu <- function(x) {length(unique(x))}
sna <- function(x) {sum(is.na(x))}
#SetWD

#### 1. Data inladen -----------------------------------------------------------------------
bag_tot_ruw <- read.delim("~/GitHub/Handige-scripts/nieuwsteBAGexport_08022021.txt")
#Dit is een export uit de database van ODBN, opgehaald met onderstaande query;
# select
# substr(d.IDENTPND,1,4) Gem_code,
# d.IDENTPND,
# d.STAPND,d.BOUWJR,
# --substr(d.VLAKGEO, 251) VLAKGEO,
# REPLACE(
#   substr(substr(d.VLAKGEO, 251),1, LENGTH(substr(d.VLAKGEO, 251))-62),
#   ' 0.0</pos><pos>', ','
# )  VLAKGEO2
# from
# DDS_PND_OPSLAG d;

#Vervolgens wordt hier in het R script nog gefilterd op alleen gemeenten in Brabant


#Wat er opgeschoond moet worden;
#Polygoon is nu een tekstveld, moet geometry worden
#Plus een XY coordinaat maken van de polygoon; het midden of een random punt pakken?

#BAG filteren op alleen gemeente Altena om de set te verkleinen
bag_ruw_sub <- bag_tot_ruw %>% filter(GEMCODE == 1959) 

sub <- Pand_Geo_VBO[1:1000,]

#### 2. -----------------------------------------------------------------------
VBO_sub <- readRDS('inrichtingen_voor_check.rds')
tic('loop2')
VBO_sub <- bag_poly_omwb

for (q in 1:nrow(VBO_sub)) {
  if (q == 1) {Bag_VBO_Poly = list()}
  
  data <- str_split(VBO_sub$VLAKGEO[[q]], ' ')
  len <- length(data)
  data[[len]] <- NULL #laatste eraf halen
  
  for (i in 1:length(data)) {
    #Hier desnoods een wissel van stelsel in zetten
    if(i == 1){Coords <- data}
    Coords$X[i] <- as.numeric(data[[i]][1])
    Coords$Y[i] <- as.numeric(data[[i]][2])
  }
  
  polygoon <- cbind(Coords$X, Coords$Y)
  
  sps <- SpatialPolygons(list(
    Polygons(list(Polygon(polygoon)
    ),VBO_sub$PAND_NUMMER[q])
  ))
 # proj4string(sps) <- proj4
  ## Data selecteren zonder de spatial data 
  df_data <- VBO_sub[q, -18] %>% mutate(ID = PAND_NUMMER) %>%
    column_to_rownames(var="ID")
  
  dat <- SpatialPolygonsDataFrame(sps, df_data)
  Bag_VBO_Poly[[q]] <- dat
  print(q)
  # Later splitten op basis van comma om er weer een vector van te maken
}




loop2 <- toc()
rm(dat, df_data, polygoon, Coords, VBO_sub, sps, i , len, q, data)
tic('Loop2.2')
Bag_VBO_Poly <- rbindlist(lapply(Bag_VBO_Poly, st_as_sf))
Bag_VBO_Poly$geometry <- st_transform(Bag_VBO_Poly$geometry, 4326)
loop2.2 <- toc()


#### 3. -----------------------------------------------------------------------

#### 4. -----------------------------------------------------------------------