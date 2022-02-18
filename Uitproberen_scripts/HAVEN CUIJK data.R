
# Inlezen bedrijven terein ------------------------------------------------
library(tidyverse)
library(sf)
library(rgdal)
library(raster)
library(rgeos)
library(sp)

# library(leaflet)
# library(rmapshaper)
Gebied <- readOGR("~/GitHub/Industrie/Ruwe data en scripts/Shape files/Bedrijf terein/BTK_25_IBBT_V.shp")

# Gebied <- sf::st_read("~/GitHub/Industrie/Ruwe data en scripts/Shape files/Bedrijf terein/BTK_25_IBBT_V.shp")#%>%
  # sf::st_transform('+proj=longlat +datum=WGS84 +no_defs')

  # st_crs(Cuijck)
  # crs(Cuijck)
  
Gebied <- Gebied[Gebied$WERKLOCA00 == "HAVEN CUIJK", "WERKLOCA00"]
proj4string(Gebied)
  
# Gebied <- Gebied %>%
  # filter(WERKLOCA00 == 'HAVEN CUIJK') %>%
  # dplyr::select(WERKLOCA00, geometry)

# Data inladen ------------------------------------------------------------

library(RODBC)

conn <- odbcConnect(dsn = 'PSOD en R', uid = "system", pwd = 'manager')

SQL <- "select a.INRNR, a.SOORT, a.STATUS, a.SBINR,
  b.Naam, b.ADRCD, -- b.INRNR,
  c.ADRESNR, c.WOONPL_BOCO_U, c.STRAAT_U, c.HUISNR, c.HUISLT, c.TOEV, c.POSTK_N, c.POSTK_A, c.X_KOORD, c.Y_KOORD, c.IDENTIFICATIE,
  e.BVGOMS,
  f.SBIOMS
from MPM01INRMIL a
left join mpm01inrnaw b on a.INRNR = b.INRNR
left join adr5_adrescyclus c on b.ADRCD = c.ADRESNR
left join MPM01INRWET d on a.INRNR = d.INRNR
left join MPM01BVG e on d.BVGCD = e.BVGCD
--left join MPM01INRSBI f on a.INRNR = f.INRNR
left join MPM01SBI f on a.SBINR = f.SBINR
where c.WOONPL_BOCO_U = 'KATWIJK NB' ;"

data1 <- sqlQuery(conn, SQL)
close(conn)


# Opschonen ---------------------------------------------------------------


data_filter <- data1 %>%
  filter(STATUS == 'O') %>%
  mutate(Y_KOORD = str_replace(Y_KOORD, '\\,', '\\.'),
         X_KOORD = str_replace(X_KOORD, '\\,', '\\.'), #) %>%
          Y_KOORD = as.numeric(Y_KOORD),
          X_KOORD = as.numeric(X_KOORD)) %>%
  filter(!is.na(Y_KOORD))

coordinates(data_filter) <- ~ X_KOORD + Y_KOORD

proj4string(data_filter) <- proj4string(Gebied)

a <-over(data_filter, Gebied)
b <- over(Gebied, data_filter)



library(sf)
# Shapefile from ABS: 
# https://www.abs.gov.au/AUSSTATS/abs@.nsf/DetailsPage/1270.0.55.004July%202016?OpenDocument
map = read_sf("~/GitHub/Industrie/Ruwe data en scripts/Shape files/Bedrijf terein/BTK_25_IBBT_V.shp")
map <- map[map$WERKLOCA00 == "HAVEN CUIJK", "WERKLOCA00"]

pnts_sf <- st_as_sf(data_filter, coords = c('X_KOORD', 'Y_KOORD'), crs = st_crs(map))


pnts <- pnts_sf %>% mutate(
  intersection = as.integer(st_intersects(geometry, map))
  , area = if_else(is.na(intersection), '', map$WERKLOCA0[intersection])
) 

eind_data <-  pnts %>%
  st_set_geometry(NULL) %>%
  mutate(`In Industrie Gebied` = ifelse(intersection == 1, "Binnen industrie gebied", "Valt buiten Industrie gebied")) %>%
  unite(Postcode, POSTK_N, POSTK_A, sep = '', na.rm = TRUE) %>%
  unite(Huisnummer, HUISNR, HUISLT, sep = '-', na.rm = TRUE) %>%
  select(
    `Inrichting nummer` = INRNR,
    `Soort Inrichting` = SOORT,
    Naam = NAAM, Postcode, Straat = STRAAT_U, Huisnummer,
    `Bevoegd gezag` = BVGOMS, `SBI omschrijving` = SBIOMS, `SBI code` = SBINR, `In Industrie Gebied`, 
  )

library(xlsx)
setwd("M:/Informatieuitwisseling/R-code/Ad_hoc/Jan Eijkmans")

xlsx::write.xlsx2(eind_data, "Inrichtingen_Haven_Cuijk_20210429.xlsx", sheetName = "Inrichtingen", row.names = FALSE)

