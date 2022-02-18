## --- --------------------- ---
## Script name: Web browser automation - uren schrijven in AFAS
## Author: Esmee Kramer
## Date Created: 17.09.2020
## --- --------------------- ---
## Notes:
##  
##  
##login -  ga naar uren schrijven
##loop over dagen van de week 
##
## --- --------------------- ---


## Libraries laden -----------------------------------------------------------------------
library(RSelenium)
library(XML)

## Je moet hiervoor al een webdriver voor chrome installeren/downloaden
## Stap 1: Run the Selenium Server and connect to it -----------------------------------------------------------------------
rds  <- rsDriver(browser=c("chrome"), chromever = "85.0.4183.87")
remDr <- rds$client
#remDr$close()

#Nagiveer naar de gewenste website
remDr$navigate("https://86118.afasinsite.nl/")
remDr$getTitle()
remDr$getStatus()


#Emailadres invoeren en op volgende klikken
#naar een bepaald element gaan door te zoeken op ID (kan ook op class of xpath)
emailbox <- remDr$findElement(using = 'id', value = "Email")
emailbox$getElementAttribute("id")
emailbox$getElementAttribute("class")
emailbox$sendKeysToElement(list("esmee-kramer@hotmail.com"))

volgendebutton <- remDr$findElement(using = 'id', value= "btnSubmit")
volgendebutton$getElementAttribute("id")
volgendebutton$getElementAttribute("class")
volgendebutton$clickElement()

#Let op het verschil tussen find element en find elements!!


##Wachtwoord invoeren en op volgende klikken
##Sleep time inbouwen voor handmatige authenticate, werkt nu nog niet
passwordbox <- remDr$findElement(using = 'id', value = "Password")
passwordbox$getElementAttribute("id")
passwordbox$getElementAttribute("class")
passwordbox$sendKeysToElement(list("AFASTrainee29"))

volgendebutton <- remDr$findElement(using = 'id', value= "btnSubmit")
volgendebutton$getElementAttribute("id")
volgendebutton$getElementAttribute("class")
volgendebutton$clickElement(); Sys.sleep(10);

##Ga naar: Uren boeken
urenboeken <- remDr$findElement(using = 'id', value= "P_C_W_2572E97E4A53273EAF9B9FB87264759F_ctl04")
urenboeken$getElementAttribute("id")
urenboeken$getElementAttribute("class")
urenboeken$clickElement()

##8 uur op de maandag invullen

#hoverblocks <- remDr$findElements(using = 'class', 'hoverblock')
                                  
                            
dag <- remDr$findElement(using = 'id', 'P_body')
dag$clickElement()
OMWB <- remDr$findElement(using = 'class', 'presetlabel1')
OMWB$clickElement()
OK <- remDr$findElement(using = 'class', 'webbutton-text')
OK$clickElement()

  
 
# OMWB$getElementAttribute("id")
# OMWB$getElementAttribute("class")





#opvragen waar je nu zit
remDr$getCurrentUrl()
remDr$getTitle

htmlParse(remDr$getPageSource()[[1]])


 
# #"\uE007" staat voor de toets enter
# 
# 
# remDr$navigate(remDr$getCurrentUrl())
# 
# 
# remDr$getCurrentUrl()
# driver$server$log()
# ##  Stap 3: Echt gaan surfen op internet -----------------------------------------------------------------------
# remDr$open()
# driver$close()
# 
# xpath helper



