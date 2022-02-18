library(leaflet)

leaflet() %>%
  
  addTiles() %>%
  # setView(-93.65, 42.0285, zoom = 4) %>%
  # addWMSTiles(
  #   "http://geoservices.knmi.nl/cgi-bin/RADNL_OPER_R___25PCPRR_L3.cgi?SERVICE=WMS&",
  #   layers = "RADNL_OPER_R___25PCPRR_L3_KNMI     ",
  #   options = WMSTileOptions(format = "image/png", transparent = FALSE),
  #   attribution = "Weather data © 2012 IEM Nexrad"
  # )
  # addTiles(Stamen.Watercolor)
  # addProviderTiles("Stamen.Watercolor") %>%
  # addWMSTiles(
  #   "https://service.pdok.nl/prorail/spoorwegen/wms/v1_0",
#   layers = "Spoorwegen WMS",
#   options = WMSTileOptions(format = "image/png", transparent = FALSE)
#   # attribution = "Weather data © 2012 IEM Nexrad"
# )
# addWMS("https://service.pdok.nl/prorail/spoorwegen/wms/v1_0?service=wms&request=GetCapabilities",
#        layers = "Spoorwegen WMS",
#        options = WMSTileOptions(format = "image/png", transparent = FALSE))
addWMSTiles("https://service.pdok.nl/prorail/spoorwegen/wms/v1_0?service=wms&request=GetCapabilities",
            # layers = 'Kilometrering',
            layers = 'overweg',
            options = WMSTileOptions(format = "image/png", transparent = TRUE))
library(leaflet.extras2)
