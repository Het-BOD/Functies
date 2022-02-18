#Libraries laden
library(readxl)       #functies: read_excel
library(stringr)      #functies: str_extract
library(dplyr)        #functies: select
library(tidyverse)

#Data inladen en samenvoegen
setwd("~/Working_directory_R/Dashboard_Klachten")
odbn <- read_excel("data/Opgeschoonde bestanden/odbn.xlsx", sheet = 2)
omwb <- read_excel("data/Opgeschoonde bestanden/omwb.xlsx", sheet = 2)
odzob <- read_excel("data/Opgeschoonde bestanden/odzob.xlsx", sheet = 3)

totaal <- rbind(odbn, omwb, odzob)
names(totaal) <- make.names(names(totaal), unique = TRUE)

#Kolommen postcode - huisnummer - huisnummer toev opschonen en samenvoegen voor zowel Locatie klacht als vermoedelijke veroorzaker

#LOCATIE
#Postcode
#NOG DOEN


#Huisnummer

huisnummers <- as.data.frame(unique(totaal$Locatie.huisnummer))

#In principe maakt het niet uit als er bijv. 9999 als huisnummer wordt genoemd, want dan kunnen deze toch niet
#gekoppeld worden aan een BAG-coordinaat, dus dit hoeven we niet op te schonen
#Wat je wel moet opschonen zijn waarden als 'nabij 12', '8a', '31-33-35', '26/28', '1 t/m 5' etc
#Je kunt hiervoor de functie str_extract gebruiken uit de stringr package
#Handige sites: https://regex101.com/ & http://edrub.in/CheatSheets/cheatSheetStringr.pdf

#Splits de kolom huisnummer op in meerdere kolommen, splitsen op een leesteken of een spatie
totaal$Locatie.huisnummer[grepl("1 t/m 59", totaal1$Locatie.huisnummer)] <- ""
totaal1 <- separate(totaal, col = Locatie.huisnummer, into = c('hsnr_nw1', 'hsnr_nw2', 'hsnr_nw3'), 
                   sep = "[:space:]*[:punct:]+|[:space:]+|\\'|\\`", remove = F)
#Als hsnr_nw1 niet begint met een nummer zet hem dan op missing (dus alle tekst weghalen)
totaal1$hsnr_nw1 <- ifelse(grepl("^[0-9]", totaal1$hsnr_nw1), totaal1$hsnr_nw1, NA)
#Om te controleren of dit goed gaat
check1 <- select(totaal1, Locatie.huisnummer, hsnr_nw1, hsnr_nw2, hsnr_nw3)
check1 <- unique(check1)
  
#er zijn nu 3 verschillende kolommen gemaakt, hieronder voeg je deze samen zodat je als de eerste kolom missing is
#de waarde uit de tweede kolom pakt, en als die ook missing is de waarde uit de derde kolom 
totaal1$hsnr_nw <- ifelse(is.na(totaal1$hsnr_nw1), totaal1$hsnr_nw2, 
                           ifelse(is.na(totaal1$hsnr_nw1) & is.na(totaal1$hsnr_nw2), 
                                  totaal1$hsnr_nw3, totaal1$hsnr_nw1))

#Om te controleren of overal waar kolom 1 missing is, kolom 2 ook missing (in kolom 2 mogen geen waarden meer staan anders is het voorgaande niet goed gegaan)
#test <- dplyr::filter(totaal1, is.na(totaal1$hsnr_nw)) 
test <- select(totaal1, Locatie.huisnummer, hsnr_nw, hsnr_nw1, hsnr_nw2, hsnr_nw3)
test <- unique(test)

#hsnr_nw1 is nu de goede kolom, die moet je nog splitsen in tekst en numeriek, en dan de tekstuele nog filteren op is niet 'en'
totaal1$hsnr1 <- str_extract(totaal1$hsnr_nw, "[0-9]+")
#In kolom 2 kan ook een huislettertoevoeging staan als het in het format "1 d" stond, dus die moet je er ook nog uithalen
totaal1$hsnra <- toupper(str_extract(totaal1$hsnr_nw1, "[:space:]*[aA-zZ]+"))
totaal1$hsnra[totaal1$hsnra=="EN"] <- NA
totaal1$hsnrb <- toupper(str_extract(totaal1$hsnr_nw2, "[:space:]*[aA-zZ]+"))
#Deze twee vervolgens samenvoegen #NOG DOEN #

check <- select(totaal1, Locatie.huisnummer, hsnr_nw1, hsnr_nw2, hsnr_nw3, hsnr1, hsnra, hsnrb, Locatie.huisnummer.toev)
check <- unique(check)


#VERMOEDELIJKE VEROORZAKER
#Postcode
#Huisnummer
class(totaal$`Vermoedelijke veroorzaker huisnummer` )
huisnummers2 <- as.data.frame(unique(totaal$`Vermoedelijke veroorzaker huisnummer`))
#Huisnummer toev

#CODE CHANTAL
#Vervangen NA waardes huisnummer toevoeging en koppelen van coordinaten 
# totaal$`Locatie huisnummer toev`[is.na(totaal$`Locatie huisnummer toev`)] <- ""
# totaal$`Locatie huisnummer toev` <- toupper(totaal$`Locatie huisnummer toev`)
# totaal$combi_klager <- paste(totaal$`Locatie postcode`, totaal$`Locatie huisnummer`,
#                             totaal$`Locatie huisnummer toev`)
# totaal$combi_klager <- gsub(" ", "", totaal$combi_klager)

# totaal$`Vermoedelijke veroorzaker huis toev.`[is.na(totaal$`Vermoedelijke veroorzaker huis toev.`)] <- ""
# totaal$`Vermoedelijke veroorzaker huis toev.` <- toupper(totaal$`Vermoedelijke veroorzaker huis toev.`)
# totaal$combi_veroorzaker <- paste(totaal$`Vermoedelijke veroorzaker postode`, totaal$`Vermoedelijke veroorzaker huisnummer`,
#                                  totaal$`Vermoedelijke veroorzaker huis toev.`)
# totaal$combi_veroorzaker <- gsub(" ", "", totaal$combi_veroorzaker)

#Samenvoegen
#Tip van Astrid: gebruik de functie unite(na.rm=T) voor het samenvoegen van postcode, hsnr, hsnr toev
#Dan hoef je niet eerst alle NA's om te zetten naar ""



