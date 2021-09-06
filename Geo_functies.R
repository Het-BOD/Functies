
# Geo Fucties -------------------------------------------------------------
### Functie die RDS omzet in coords voor leaflet op basis van losse x en y coords.
## De projectie is aan te passen als je weet welke crs hier voor nodig is
Swap <- function(df, X, Y, projection = CRS("+init=epsg:28992"), into = CRS("+proj=longlat +datum=WGS84")){
  require(sp) ; require(sf) ; require(magrittr)
  options(digits = 14)
  X <- substitute(X)
  Y <- substitute(Y)

  df %<>% filter(!is.na(df[X]))
  XCOORD <- sapply(df[X], gsub, pattern = ",", replacement = ".") %>% as.numeric()
  YCOORD <- sapply(df[Y], gsub, pattern = ",", replacement = ".") %>% as.numeric()
  coords <- cbind(XCOORD, YCOORD) %>% as.data.frame()
  coordinates(coords) <- coords
  proj4string(coords) <- projection
  new_coords <- spTransform(coords, into)
  
  `<-`(df[X],new_coords@coords[,1])
  `<-`(df[Y],new_coords@coords[,2])
  return(df)
}


