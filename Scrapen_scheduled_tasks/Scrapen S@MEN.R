## --- --------------------- ---
## Script name: Web browser automation - S@MEN scrapen
## Author: Esmee Kramer
## Date Created: 23.09.2020
## --- --------------------- ---

## Libraries laden -----------------------------------------------------------------------
library(RSelenium)
library(XML)
library(tidyverse)

#Je moet hiervoor al een webdriver voor chrome installeren/downloaden
#Stap 1: Run the Selenium Server and connect to it -----------------------------------------------------------------------
rds  <- rsDriver(browser=c("chrome"), chromever = "91.0.4472.19")
remDr <- rds$client
#remDr$close()

#Nagiveer naar de gewenste website -----------------------------------------------------------------------
remDr$navigate("https://samenpartner.gelderland.nl/Login.aspx")
remDr$getTitle()
remDr$getStatus()

#Zoek naar de specifieke elementen waar je text wilt invoeren of een mouseclick op wilt uitvoeren
#Let op het verschil tussen find element en find elements!!
#Naar een bepaald element gaan door te zoeken op ID (kan ook op class of xpath)
emailbox <- remDr$findElement(using = 'id', value = "LoginControl_UserName")
emailbox$getElementAttribute("id")
emailbox$getElementAttribute("class")
emailbox$sendKeysToElement(list("ekramer"))

passwordbox <- remDr$findElement(using = 'id', value = "LoginControl_Password")
passwordbox$getElementAttribute("id")
passwordbox$getElementAttribute("class")
passwordbox$sendKeysToElement(list("S@menBOD1!"))

inlogbutton <- remDr$findElement(using = 'name', value= "LoginControl$LoginButton")
inlogbutton$getElementAttribute("id")
inlogbutton$getElementAttribute("class")
inlogbutton$clickElement()

#Alleen eigen regio uitvinken
regiobutton <- remDr$findElement(using = 'id', value= "ContentPlaceHolder1_chkAlleenEigenRegio")
regiobutton$getElementAttribute("id")
regiobutton$getElementAttribute("class")
regiobutton$clickElement()

#Headers ophalen om vervolgens een lege tabel te specificeren en te loopen over pagina's  -----------------------------------------------------------------------
xmlcode <- htmlParse(remDr$getPageSource()[[1]])
xmlcode
datahead <- xmlToDataFrame(nodes=getNodeSet(xmlcode,"//tbody/tr/th")) %>% mutate(colnames=ifelse(is.na(a), text, a)) %>% select(colnames) %>% .[9:19,] 
data_totaal <- data.frame(matrix(ncol=11, nrow=0)); colnames(data_totaal) <- datahead

#Op iedere pagina zijn de relevante regels rijen 3 tot en met 16 in de tabel
rows <- c(3:16)
pages <- c(2:11)
for (p in pages){
  for (x in rows){
    databody_pagex <- xmlToDataFrame(nodes=getNodeSet(xmlcode, paste0('///*[@id="ContentPlaceHolder1_dgrKlachten"]/tbody/tr[', x, "]")))
    emptycols <- colSums(databody_pagex == " ") == nrow(databody_pagex)
    databody_pagex <- databody_pagex[!emptycols]
    colnames(databody_pagex) <- datahead
    data_totaal <- rbind(data_totaal, databody_pagex)
    }
  
    nextpage <- remDr$findElement(using = 'xpath', value= paste0('//*[@id="ContentPlaceHolder1_dgrKlachten"]/tbody/tr[1]/td/table/tbody/tr/td[', p, ']/a', sep=""))
    nextpage$getElementAttribute("id")
    nextpage$getElementAttribute("class")
    nextpage$clickElement()
    xmlcode <- htmlParse(remDr$getPageSource()[[1]])
}

#10 pagina's maal 14 regels per pagina is 140 observaties

#Met onderstaand pijltje ga je naar de volgende set aan paginanummers
pijltje <- remDr$findElement(using = 'xpath', value= paste0('//*[@id="ContentPlaceHolder1_dgrKlachten"]/tbody/tr[1]/td/table/tbody/tr/td[12]/a'))
pijltje$getElementAttribute("id")
pijltje$getElementAttribute("class")
pijltje$clickElement()

pages2 <- c(11:15)
for (p in pages2){
  for (x in rows){
    databody_pagex <- xmlToDataFrame(nodes=getNodeSet(xmlcode, paste0('///*[@id="ContentPlaceHolder1_dgrKlachten"]/tbody/tr[', x, "]")))
    emptycols <- colSums(databody_pagex == " ") == nrow(databody_pagex)
    databody_pagex <- databody_pagex[!emptycols]
    colnames(databody_pagex) <- datahead
    data_totaal <- rbind(data_totaal, databody_pagex)
  }

    nextpage <- remDr$findElement(using = 'xpath', value= paste0('//*[@id="ContentPlaceHolder1_dgrKlachten"]/tbody/tr[1]/td/table/tbody/tr/td[', p, ']/a', sep=""))
    nextpage$getElementAttribute("id")
    nextpage$getElementAttribute("class")
    nextpage$clickElement()
    xmlcode <- htmlParse(remDr$getPageSource()[[1]])
}


#Alleen brabant regio's eruithalen -----------------------------------------------------------------------
data_totaal <- data_totaal[,1:11]
data_totaal_BRA <- data_totaal %>% filter(Eigenaar %in% c("OMWB", "ODZOB", "ODBN"))

#Data wegschrijven -----------------------------------------------------------------------
write.csv(data_totaal, paste0("C:/Users/omwekr02/Documents/Scrapen_scheduled_tasks/SAMEN_data_gescraped_", Sys.Date(), ".csv"), row.names=FALSE)



##Tot welke pagina moeten we doorgaan? Iets inbouwen dat de loop stopt als hij een record ziet wat al bekend is?


### TESTEN DOORLINKEN -----------------------------------------------------------------------
# rows <- c(3:16)
# //*[@id="ContentPlaceHolder1_dgrKlachten"]/tbody/tr[3]/td[13]/input
# 
# //*[@id="ContentPlaceHolder1_dgrKlachten"]/tbody/tr[4]/td[13]/input

# document <- remDr$findElement(using = 'xpath', value= ('//*[@id="ContentPlaceHolder1_dgrKlachten"]/tbody/tr[3]/td[13]/input'))
# document$getElementAttribute("id")
# document$getElementAttribute("class")
# document$clickElement()
# 
# xmlcode2 <- htmlParse(remDr$getPageSource()[[1]])
# ##Hier het stukje vermoedelijke veroorzaker van scrapen?
# 
# terugknop <- remDr$findElement(using = 'xpath', value= ('//*[@id="ContentPlaceHolder1_MeldingOverzichtButtons"]/input[1]'))
# terugknop$getElementAttribute("id")
# terugknop$getElementAttribute("class")
# terugknop$clickElement()
  




