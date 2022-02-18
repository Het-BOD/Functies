### Aanzet tot opschonen van adres gegevens
dataframe <- voi_zaken

dataframe <- dataframe %>%
  select(Alternatief = PHNHL) %>% distinct() %>%
  filter(grepl("^[0-9]{4}[A-Z]{2}[0-9]+", Alternatief)) %>%
  mutate(overig = str_extract(Alternatief, "[0-9]{4}[A-Z]{2}"),
         length = str_length(overig),
         extra = str_trunc(Alternatief, str_length(Alternatief) - length, 'left', ellipsis = ''),
         extra = str_replace_all(extra, "|\\)|TO|NAAST|NABIJ|BIJ|ROTT|SWINK|ONGENUMMERD|ONG.|ONG|T.O.|NB|NULL", ''),
         extra = str_replace_all(extra, "AA", 'A'),
         extra = str_replace_all(extra,'EN|\\+|\\/|,|\\(|--', '-'),
         extra = str_remove_all(extra, ' '),
         extracheck = ifelse(grepl('-', extra), extra, NA),
         opvallend = ifelse(str_length(str_extract(extracheck, "[0-9]*")) > 3, str_extract(extracheck, "[0-9]*[A-Z]?"), NA),
         split1 = substring(opvallend, 1, str_length(str_extract(opvallend, "[0-9]*")) / 2 ),
         split2 = substring(opvallend, str_length(opvallend) / 2 + 1),
         # split2 = ifelse(!is.na(split2), split2, NA),
         extra2 = extra,
         splitter = extra
         # splitter = str_split(extra, "[A-Z]", n = 2)
  ) %>% 
  separate(extra2, c("col1", "col2", 'col3'),'-') %>% 
  separate(splitter, c("Split1", "Split2"),"[A-Z]") %>% 
  # mutate(col3 = ifelse(col2 == "[A-Z]*", paste0(str_extract(col2, "[0-9]*"),col2), NA)) %>%
  mutate(check = ifelse((as.numeric(col1) - as.numeric(col2)) > 2|(as.numeric(col2) - as.numeric(col1)) > 2, "Extra toevoegen", NA),
         col4 = ifelse(col2 %in% c('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'),
                       paste0(str_extract(col1, "[0-9]*"),col2), 
                       NA),
         # col1 = ifelse(!is.na(extracheck), NA, col1),
         # split1 = ifelse(!is.na(extracheck), NA, split1),
         Split2 = ifelse(grepl("^[0-9]", Split2), Split2, NA)) %>%
  select(-Split1, -overig, -length, -opvallend, -extra, - check) #%>%

Output <- dataframe %>%
  pivot_longer(-Alternatief) %>%
  filter(!is.na(value)) %>%
  mutate(col1 = str_extract(Alternatief, "[0-9]{4}[A-Z]{2}")) %>% 
  rename(OUD_PHNHL = Alternatief) %>% 
  unite(PHNHL, c(col1, value), sep = '') %>%
  select(-name) %>% 
  filter(grepl("[0-9]{4}[A-Z]{2}[0-9]+", PHNHL),
         str_length(PHNHL) > 6) %>% distinct()


# Checking ----------------------------------------------------------------

check <- dataframe %>%
  filter(str_length(Alternatief) <= 6)

check <- dataframe %>%
  filter(grepl('[0-9]{4}[A-Z]{2}[0-9]+[A-Z]?$', PHNHL))


