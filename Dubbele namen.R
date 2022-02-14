#### Gebuirk maken van een naam vergelijking "jw" en mogelijk andere (kijken voor een combinatie)
#### mogelijk bedrijven met een enkele distance van text nog toevoegen
#### filter alle leestekens vooraf eruit zodat blokken text overeen komen 
#### Baseer

#### check de SBI OMSCHRIJVING, eerste woord met ghost code om de vergelijking te maken.
#### obengon gas eruit

#### Library ####
library(tidyverse)
library(RODBC)
library(stringdist)
library(tidystringdist)
library(janitor)
library(readxl)
library(lubridate)
library(tidyverse)
library(readxl)
library(data.table)


paste3 <- function(..., sep = "") {
  L <- list(...)
  L <- lapply(L,function(x) {x[is.na(x)] <- ""; x})
  ret <- gsub(paste0("(^",sep,"|",sep,"$)"),"",
              gsub(paste0(sep,sep),sep,
                   do.call(paste,c(L,list(sep = sep)))))
  is.na(ret) <- ret == ""
  toupper(ret)
}
#### ####
options(scipen=999)
setwd("M:/Informatieuitwisseling/R-code/Inrichtingen Dubbel")

conn <- odbcConnect('PSOD en R', uid = "system", pwd = 'manager')

script <- "SELECT a.INRNR, a.SOORT, a.STATUS, a.OPHDAT, a.SBINR, a.LOCOMS, a.TYPECD,
b.NAAM, b.ADRCD ,
c.WOONPL_BOCO_U, c.STRAAT_U, HUISNR, HUISLT, POSTK_N, POSTK_A, GEMEENTEKODE, IDENTIFICATIE
FROM MPM01INRMIL a 
LEFT JOIN MPM01INRNAW b ON a.INRNR = b.INRNR
LEFT JOIN ADR5_ADRESCYCLUS c ON b.ADRCD = c.ADRESNR"

df <- sqlQuery(conn, script, stringsAsFactors = F) 

close(conn)

setwd('M:/informatieuitwisseling/R-code/Inrichtingen Dubbel')

#### Inladen SBI codes ####
SBI_CODE <- read_excel('SBI Lijst.xlsx', skip= 2) %>%
  select(SBI = 'SBI nr.', SBI_OMS = 'SBI omschrijving')%>%
  filter(SBI != is.na(SBI)) %>%
  mutate(SBI_OMS = word(SBI_CODE$SBI_OMS, 1),
         SBI_OMS = str_remove_all(SBI_OMS, '[.\'-,:]')) %>%
  group_by(SBI_OMS) %>%
  mutate(Aantal = n()) %>% ungroup()

#### opschonen dataset en bijvoegen van SBI omschrijving ####
Open_Inrichting <- df %>%
  left_join(select(SBI_CODE, SBI, SBI_OMS), by = c('SBINR' = 'SBI')) %>%
  mutate(POSTCODE = paste3(POSTK_N,POSTK_A),
         ID = paste3(POSTCODE, HUISNR, HUISLT),
         NAAM = toupper(NAAM),
         NAAM = trimws(NAAM))%>%
  filter(STATUS == 'O',
         ID != 0) %>% 
  relocate(ID, ADRCD) 

zelfde_ID <- Open_Inrichting[duplicated(Open_Inrichting$ID),] %>% select(ID) %>%
  left_join(Open_Inrichting, by = 'ID')
#### extra ####
# zelfde_NAAM <- Open_Inrichting[duplicated(Open_Inrichting$NAAM),] %>% select(NAAM) %>%
#   left_join(Open_Inrichting, by = 'NAAM')
# 
# 
# Totaal_Dubbel <- zelfde_ID %>%
#   rbind(zelfde_NAAM) %>% distinct() %>%
#   relocate(ID, SBINR, NAAM, TYPECD) 

  # filter(grepl("^[[:digit:]]+$",GEMEENTEKODE))


####Dubbel met zelfde SBI ####

SBI <- zelfde_ID %>%
  select(ID, INRNR,SBI_OMS, SBINR, NAAM) %>%
  left_join(select(zelfde_ID, ID, INRNR, SBINR, SBI_OMS, NAAM, TYPECD), by = 'ID' ) %>%
  # filter(SBINR.x == SBINR.y,
  #        INRNR.x != INRNR.y) %>%
  filter(SBI_OMS.x == SBI_OMS.y|is.na(SBI_OMS.y),
           INRNR.x != INRNR.y) %>%
   distinct() %>%
  group_by(ID) %>%
  mutate(Aantal = n())

##### GEMEENTE CODE DIE MET LETTERS BEGINNEN ALS CSV2 EN MAILEN!!!!#####

# df12 <- df %>%
#   mutate(POSTCODE = paste3(POSTK_N,POSTK_A),
#          ID = paste3(POSTCODE, HUISNR, HUISLT))%>%
#   filter(STATUS == 'O',
#          ID != 0) %>%
#   relocate(ID, ADRCD) %>%
#   filter(!grepl("^[[:digit:]]+$",GEMEENTEKODE))
# write.csv2(df12, 'Vreemde Gemeente Code.csv')


#### lijst maken met dubbele inrichtingen op basis van de naam ####

New_DF <- data.frame(matrix(ncol = 2, nrow = 0))
x <- c("V1", "V2")

colnames(New_DF) <- x

##### Combinatie van alle namen maken ####
L_Postcode <- Open_Inrichting$POSTCODE[grepl("^[[:digit:]]+$", Open_Inrichting$GEMEENTEKODE)] %>% 
  unique()
L_PostN <- Open_Inrichting$POSTK_N[grepl("^[[:digit:]]+$", Open_Inrichting$GEMEENTEKODE)] %>% 
  unique()

#####Samen zetten van bedrijfs namen per

for (i in L_Postcode){
  # test <- lijst[i]
dfsub <- Open_Inrichting %>% filter(POSTCODE == paste(i))
dfsubs <- as.character(dfsub$NAAM) %>% unique()
if(length(dfsubs) <= 1) {
  #break
  next
  }
dfsub2 <- tidy_comb_all(dfsub, NAAM)
New_DF <- rbind(New_DF, dfsub2)
}

# New_DF <- New_DF[FALSE,]

DF_Namen <- Open_Inrichting %>%
  left_join(New_DF, by = c('NAAM' = 'V1'), copy = T) %>%
  left_join(select(Open_Inrichting, NAAM, POSTCODE_ALT = POSTCODE, INRNR_Alt = INRNR, 
                   SBINR_Alt = SBINR, ID_Alt = ID, Nummer_Alt = POSTK_N), by = c('V2' = 'NAAM')) %>%
  filter(
         NAAM != 'LEEGSTAND',
         POSTK_N == Nummer_Alt,
         SBINR == SBINR_Alt
         ) %>%
  select(INRNR, INRNR_Alt, NAAM, Alt_ = V2, POSTCODE, POSTCODE_ALT, 
         SBINR, SBINR_Alt, ID, ID_Alt, POSTK_N 
  ) %>% 
       mutate(
        # NAAM = str_remove_all(NAAM, '[.\']'),
        # Alt_ = str_remove_all(Alt_, '[.\']'),
        jw = stringsim(NAAM, Alt_, method='jw'),
        lv = stringsim(NAAM, Alt_, method='lv')) %>%
      group_by(INRNR,NAAM, SBINR) %>%  
      arrange(desc(jw, lv)) %>% #slice_head(n=3) %>%
      ungroup() %>%
      filter(jw > 0.8,
             lv > 0.8)#%>% distinct()

Inrichtingen_Lijst <- DF_Namen %>%
  select(INRNR, SBINR, NAAM, ID) %>%
  rbind(select(DF_Namen, INRNR=INRNR_Alt, SBINR=SBINR_Alt, NAAM=Alt_, ID=ID_Alt)) %>%
  rbind(as.data.frame(select(SBI, INRNR=INRNR.x, SBINR=SBINR.x, NAAM=NAAM.x, ID))) %>%
  distinct() %>%
  left_join(Open_Inrichting, ny = c('INRNR', 'SBINR', 'ID'))

write.csv2(Inrichtingen_Lijst, 'Mogelijke_Dubbele_Inrichtingen.csv')

#### Uit gecodeerd voor nu ####
# lijst <- c(5411, 5374, 5375)
# 
# dfsub1 <- df1 %>% filter(POSTK_N == 5411) %>% 
#   tidy_comb_all(NAAM)
# dfsub2 <- df1 %>% filter(POSTK_N == 5374) %>% 
#   tidy_comb_all(NAAM)
# dfsub3 <- df1 %>% filter(POSTK_N == 5375) %>% 
#   tidy_comb_all(NAAM)
# 
# Samen <- rbind(dfsub1, dfsub2, dfsub3) #%>%


# df2 <- Open_Inrichting %>%
#   filter(POSTCODE == '5431NX')


##### kijken hoe we SBI codes willen gebruiken
#### filteren op naam werk echt alleen voor de naam! Ook nog kijken naar Duplicates
##### van Adres en bedrijf op adres met andere SBI (Dit zal kloppen)

# Lijst SBI/ dfback pakken met IRNR - ID
# bind aan zetten
# Left join vanaf orginele bestand
#distinct erop


test <- Inrichtingen_Lijst %>%
  filter(INRNR %in% c(26914, 26878))

tester2 <- Open_Inrichting %>%
  filter(is.na(POSTCODE))
