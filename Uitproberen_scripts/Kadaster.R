library(httr)

loops = c(0,1001,2001,3001,4001,5001,6001,7001,8001,9001,10001,11001,12001)
loop=0

empty_df = list()
for (loop in loops) {
  urls <- parse_url("https://geodata.nationaalgeoregister.nl/kadastralekaart/wfs/v4_0?")
  urls$query <- list(service = "wfs",
                    version = "2.0.0",
                    request = "GetFeature",
                    typename = "kadastralekaartv4:perceel",
                    srsName  = "EPSG:28992",
                    startindex = loop,
                    bbox = bbox,
                    outputFormat='json')
  request <- httr::build_url(urls)

  
  
  data <- sf::st_read(request)
  empty_df <- list.append(empty_df, data)
  print(paste0("startindex ", loop," - entities: ",nrow(data), " percelen"))
  if(nrow(data) < 1000) {percelen_sf <- rbindlist(empty_df, use.names=TRUE) %>% st_as_sf(); break}
}
rm(data, empty_df)



httr::GET(
  url = "https://geodata.nationaalgeoregister.nl/kadastralekaart/wfs/v4_0?",
  query = list(
    service = "WFS",
    version = "2.0.0",
    request = "GetFeature",
    typename = "kadastralekaartv4:perceel",
    outputFormat = "json"
  )
) -> res


dat <- httr::content(res)
data <- dat$features

data2 <- unlist(data) %>% as.data.frame()
