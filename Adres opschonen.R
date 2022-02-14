#### Klaarzetten ####
library(tidyverse)


## Postcode extraheren wanneer er spatie zit tussen de cijfers en letters en de string begint met de postcode.
#zoals KVK
Dataset_schoner <- Data_set %>%
  select(HUISNR, TOEV_HSNR, PC_WPL) %>%
  mutate(pc = str_extract(PC_WPL, '^[0-9]{4}[ ][a-zA-Z]{2}[ ]'),
         pc = str_remove_all(pc, ' ')) %>%
  filter(!is.na(pc)) %>%
  mutate(Huisletter = str_extract(TOEV_HSNR, '[a-zA-Z]{1}[0-9]?'))
#(r)ik zorg ervoor dat de overige kolommen hier ook nog bij komen op basis van de KVK set. Misschien leuk om daarna dit te testen tegen de 
#KRO set

## Adresgegevens opschonen DC ## 
DC <- DC %>% mutate(Postcode =  str_replace(location_zip,  ' ',  ''),
                    Huisnummer = str_extract(location_address, '([[0-9]]+.?[[a-zA-Z]]?)$'),
                    Huisletter = str_extract(Huisnummer, '[[a-zA-Z]]+') %>% toupper(),
                    Huisnummer = str_extract(Huisnummer, '[[0-9]]+'))

## Adresopschoning KRO, waar er huisnummers ook in de straatnaam zitten en niet in de huisnummer kolom
## Nieuwe kolom toevoegen van postcode+huisnummer+huisletter ##
# KRO
KROsub$huisletter[is.na(KROsub$huisletter)] <- ""
KROsub$Huisnr <- str_extract(KROsub$straatnaam, '([[0-9]]+.?[[a-zA-Z]]?)$')
KROsub$Huisnr <- str_extract(KROsub$Huisnr, '[[0-9]]+')
KROsub$Huisnr <- ifelse(is.na(KROsub$huisnr), KROsub$Huisnr, KROsub$huisnr)
KROsub$PCHNHL <- paste(KROsub$pc6, KROsub$Huisnr, KROsub$huisletter)
KROsub$PCHNHL <- gsub(" ", "", KROsub$PCHNHL)
KROsub$PCHNHL <- toupper(KROsub$PCHNHL)


# mutate(Postcode = str_replace(Postcode, ' ', ''),
#        Huisnummer = str_extract(Straat, '([[0-9]]+.?[[a-zA-Z]]?)$'),
#        Huisnummer = str_replace_all(Huisnummer, "[[:punct:][ ]]", ''),


### Wat willen we hebben?
#PC6            Postcode 6 (4cijfers 2 hoofdletter geen spaties aanwezig)
#Huisnr         HuisNummer (enkel nummer)
#Huisltr        HuisLetter (enkele Hoofdletter)
#Huis_toev_ruw  De nog te verwerken toevoegingen voor het huisnummer uit de database welke verwerkt moet worden naar huisnummer/huiletter en daadwerkelijke Huis_toev
#Huisnr_toev    Huisnummer toevoeging??? (overige letters en nummers voor verdere verwerking){denk aan t/m, -, ,, overige bevindsten}
##### nog bespreken met externe partij. Hoe pakken andere dit aan?

#Gemeente       Gemeente (CamelCase Gemeente)
#Woonplaats     Woonplaats (CamelCase Woonplaats)
#Straatnaam     Straatnaam (CamelCase Straatnaam)
#PCHNHL         Koppel tabel (4cijfers 2 hoofdletters 1 of meer cijfers en optionele hoofdletter)
#Script PCHN Naam check
