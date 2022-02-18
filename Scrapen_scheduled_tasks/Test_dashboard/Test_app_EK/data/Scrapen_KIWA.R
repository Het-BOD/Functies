## --- --------------------- ---
## Script name: Web browser automation - KIWA scrapen
## Author: Esmee Kramer
## Date Created: 23.09.2020
## --- --------------------- ---

## 0. Libraries laden -----------------------------------------------------------------------
library(RSelenium)
library(XML)
library(tidyverse)
library(netstat)
library(lubridate)
library(xlsx)

binman::list_versions("chromedriver")
#netstat::free_port()
#14415L
#4567L

#Je moet hiervoor al een webdriver voor chrome installeren/downloaden
## 1. Run the Selenium Server and connect to it -----------------------------------------------------------------------
rds  <- rsDriver(browser=c("chrome"), chromever = "87.0.4280.20", port = 14415L)
remDr <- rds$client
remDr$open()

## 2. Nagiveer naar de gewenste website -----------------------------------------------------------------------
remDr$navigate("https://dataportal.kiwa.info/site/login")
remDr$getTitle()
remDr$getStatus()

#Zoek naar de specifieke elementen waar je text wilt invoeren of een mouseclick op wilt uitvoeren
#Let op het verschil tussen find element en find elements!!
#Naar een bepaald element gaan door te zoeken op ID (kan ook op class of xpath)
emailbox <- remDr$findElement(using = 'id', value = "loginform-username")
emailbox$getElementAttribute("id")
emailbox$getElementAttribute("class")
emailbox$sendKeysToElement(list("jeroen.bax@odzob.nl"))

passwordbox <- remDr$findElement(using = 'id', value = "loginform-password")
passwordbox$getElementAttribute("id")
passwordbox$getElementAttribute("class")
passwordbox$sendKeysToElement(list("R000153330"))

inlogbutton <- remDr$findElement(using = 'name', value= "login-button")
inlogbutton$getElementAttribute("id")
inlogbutton$getElementAttribute("class")
inlogbutton$clickElement()

remDr$getCurrentUrl()
remDr$navigate("https://dataportal.kiwa.info/project")
remDr$getCurrentUrl()

#Huidige dataset inladen, in de loop is ingebouwd dat hij stopt met rbinden als er dubbele records inzitten
datum_minus1 <- Sys.Date() %>% ymd() -1
datum_minus1 <- format(datum_minus1, "%d-%m-%Y")
datum_minus3 <- Sys.Date() %>% ymd() -3
datum_minus3 <- format(datum_minus3, "%d-%m-%Y")
datum <- ifelse((lubridate::wday(Sys.Date(), week_start = getOption("lubridate.week.start", 1)) == 1),
                datum_minus3, datum_minus1)
                
#huidig2 <- readRDS("KIWA_data_gescraped_2020-11-09.rds")
huidig2 <- readRDS(paste0("C:/Users/omwekr02/Documents/Scrapen_scheduled_tasks/Test_dashboard/Test_app_EK/data/KIWA_data_gescraped_", datum, ".rds", sep=""))
huidig <- huidig2 %>% select(-Scrapedatum)
length(unique(huidig$`Certificaat nr`)) == nrow(huidig)
huidig <- huidig[11:4000,]
data_totaal <- huidig
datahead <- names(data_totaal)

#huidig2 <- huidig2[11:4000,] %>% select(`Certificaat nr`, Scrapedatum)

# data_totaal <- data.frame(matrix(ncol=9, nrow=0)); colnames(data_totaal) <- datahead
pages <- c(1:10)
for (x in pages) {
  #Naar de pagina gaan
  remDr$navigate(paste0("https://dataportal.kiwa.info/project/index?page=", x))
  print(remDr$getCurrentUrl())
  ##Tabel scrapen en toevoegen aan data_totaal
  xmlcode <- htmlParse(remDr$getPageSource()[[1]])
  datahead <- xmlToDataFrame(nodes=getNodeSet(xmlcode,"//thead/tr/th")) %>% mutate(colnames=ifelse(is.na(a), text, a)) %>% select(colnames) %>% .$colnames
  databody_pagex <- xmlToDataFrame(nodes=getNodeSet(xmlcode,"//tbody/tr"))
  colnames(databody_pagex) <- datahead
  data_totaal <- rbind(databody_pagex, data_totaal)
  print(nrow(unique((data_totaal))))
  print(nrow((data_totaal)))
  if(nrow(unique(data_totaal)) < nrow(data_totaal)) {
    break
  }
}

data_totaal <- data_totaal %>% unique() %>% left_join(huidig2, by = "Certificaat nr") %>% 
  mutate(Scrapedatum = ifelse(is.na(Scrapedatum), format(Sys.Date(), "%d-%m-%Y"), Scrapedatum))

write.xlsx(data_totaal, paste0("C:/Users/omwekr02/Documents/Scrapen_scheduled_tasks/Test_dashboard/Test_app_EK/data/KIWA_data_gescraped_", format(Sys.Date(), "%d-%m-%Y"), ".xlsx"), row.names=FALSE)
write_rds(data_totaal, paste0("C:/Users/omwekr02/Documents/Scrapen_scheduled_tasks/Test_dashboard/Test_app_EK/data/KIWA_data_gescraped_", format(Sys.Date(), "%d-%m-%Y"), ".rds"))


print(paste0(Sys.Date(), ": Dit script heeft gerund", sep=""))

remDr$close()
