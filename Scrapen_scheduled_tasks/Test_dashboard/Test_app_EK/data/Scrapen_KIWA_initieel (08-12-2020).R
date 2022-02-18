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

#netstat::free_port()
#14415L
#4567L

#Je moet hiervoor al een webdriver voor chrome installeren/downloaden
## 1: Run the Selenium Server and connect to it -----------------------------------------------------------------------
rds  <- rsDriver(browser=c("chrome"), chromever = "87.0.4280.20", port = 14415L)
remDr <- rds$client
#remDr$open()

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

## 3. Data scraping -----------------------------------------------------------------------
#Leeg dataframe specificeren met de juiste kolomnamen
kolomnamen <- c("Certificaat nr", "Locatie", "Adres", "Plaats", "Beoordelingsrichtlijn",
"Certificaathouder", "Start gepland", "Eind gepland", "Afgerond")     

data_totaal2 <- data.frame(matrix(ncol=9, nrow=0))
names(data_totaal2) <- kolomnamen
# data_totaal <- data.frame(matrix(ncol=9, nrow=0)); colnames(data_totaal) <- datahead
pages <- c(1:200)
for (x in pages) {
  #Naar de pagina gaan
  remDr$navigate(paste0("https://dataportal.kiwa.info/project/index?page=", x))
  print(remDr$getCurrentUrl())
  ##Tabel scrapen en toevoegen aan data_totaal
  xmlcode <- htmlParse(remDr$getPageSource()[[1]])
  datahead <- xmlToDataFrame(nodes=getNodeSet(xmlcode,"//thead/tr/th")) %>% mutate(colnames=ifelse(is.na(a), text, a)) %>% select(colnames) %>% .$colnames
  databody_pagex <- xmlToDataFrame(nodes=getNodeSet(xmlcode,"//tbody/tr"))
  colnames(databody_pagex) <- datahead
  data_totaal2 <- rbind(data_totaal2, databody_pagex)
  print(nrow(unique((data_totaal2))))
}

data_totaal2 <- data_totaal2 %>% unique()
data_totaal2$Scrapedatum <-  format(Sys.Date(), "%d-%m-%Y")

## 4. Data wegschrijven -----------------------------------------------------------------------
write.xlsx(data_totaal2, paste0("C:/Users/omwekr02/Documents/Scrapen_scheduled_tasks/Test_dashboard/Test_app_EK/data/KIWA_data_gescraped_", format(Sys.Date(), "%d-%m-%Y"), ".xlsx"), row.names=FALSE)
write_rds(data_totaal2, paste0("C:/Users/omwekr02/Documents/Scrapen_scheduled_tasks/Test_dashboard/Test_app_EK/data/KIWA_data_gescraped_", format(Sys.Date(), "%d-%m-%Y"), ".rds"))
