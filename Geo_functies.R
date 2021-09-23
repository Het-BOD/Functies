
### Geo functies -------------------------------------------------------------
# Functie die RDS omzet in coords voor leaflet op basis van losse x en y coords -------------------------------------------------------------
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


# Functie die coordinaten toevoegt dmv Azure Maps API -------------------------------------------------------------
add_coords <- function(df, adreskolom) {
  
  #Algemene correcties
  require(httr); require(crul)
  
  df <- df %>% mutate(X_coord = NA, Y_coord = NA) %>% rename(Adres = Adres)
  adreskolom <- substitute(adreskolom)
  
  #Loop over dataframe
  for (i in 1:nrow(df)){
    
    #Progress bar opstarten
    if(i == 1){
      pb <- txtProgressBar(min = 0, max = nrow(df), style = 3)
    }
    
    tryCatch({
      #Basisquery voor Azure Maps API
      key = "XI_tNqkJNEp4SrChlahsFYTYWsHHmw8b7dnq0s9EjZ8"
      query = df$Adres[i]
      url = paste0('https://atlas.microsoft.com/search/address/json?api-version=1.0&subscription-key=', key, '&query=', query, sep="")
      
      res <- HttpClient$new(
        url = url,
        auth = none)
      x <- res$get()
      output <- jsonlite::fromJSON(x$parse("UTF-8"))
      
      #Resultaten toevoegen aan df
      df$X_coord[i] <- output$results$position$lon[1]
      df$Y_coord[i] <- output$results$position$lat[1]
      
      #Progress bar updaten
      setTxtProgressBar(pb, i)
      
      #Resultaat printen
      if (i == nrow(df)) {
        print(paste0("Er is voor ", sna(df$X_coord) , " van de ", nrow(df) ," regels geen coordinaat toegevoegd, dat is ", round(sna(df$X_coord) / nrow(df) * 100,1) , "%"))
        
        #Foutieve coordinaten eruit filteren (kunnen komen door niet complete adresgegevens)
        bbox_brabant <- c(4.190124, 51.220909, 6.048121, 51.830751)
        df <- df %>% mutate(X_coord = ifelse(X_coord > bbox_brabant[1] & X_coord < bbox_brabant[3], X_coord, NA),
                            Y_coord = ifelse(Y_coord > bbox_brabant[2] & Y_coord < bbox_brabant[4], Y_coord, NA))
        
        print(paste0("Na het eruit halen van coordinaten buiten brabant zijn er ", sna(df$X_coord) , " missende coordinaten"))
      }
    }, error = function(e) {} )}
  
  #Clean environment and close function  
  close(pb)
  rm(key, query, url, x, res, output, i)
  return(df)
}



# ## Progress bar
# n_iter <- 20
# for (i in 1:20){
#   if(i == 1){
#     pb <- winProgressBar(title = "Windows progress bar", # Window title
#                          label = "Percentage completed", # Window label
#                          min = 0,      # Minimum value of the bar
#                          max = n_iter, # Maximum value of the bar
#                          initial = 0,  # Initial value of the bar
#                          width = 300L) # Width of the window
#   }
# 
#   #---------------------
#   # Code to be executed
#   #---------------------
# 
#   Sys.sleep(0.1) # Remove this line and add your code
# 
#   #---------------------
# 
#   pctg <- paste(round(i/n_iter *100, 0), "% completed")
#   setWinProgressBar(pb, i, label = pctg) # The label will override the label set on the
#   # winProgressBar function
# };close(pb);beepr::beep(sound = 8) # Close the connection



### Geo data inladen -----------------------------------------------------------------------

####################################
## Provinciegrens en bbox_brabant ##
####################################
url <- parse_url("https://geodata.nationaalgeoregister.nl/bestuurlijkegrenzen/wfs?")
url$query <- list(request = "GetFeature",
                  typename = "bestuurlijkegrenzen:provincies",
                  service = "wfs",
                  srsName  = "EPSG:4326",
                  outputFormat='json')
request <- build_url(url);request
provincies <- sf::st_read(request)
brabant <- provincies[provincies$provincienaam == "Noord-Brabant",]
bbox_brabant <- sf::st_bbox(brabant$geom)
rm(url, request, provincies)
