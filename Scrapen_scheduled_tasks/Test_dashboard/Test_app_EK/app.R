library(shiny)
library(DT)
library(AzureStor)
library(tidyverse)

#Gescrapte data inladen, daarin zit al en kolom met de scrapedatum dus daarvaar kunnen we de max aanroepen voor de meest recente datum
#kiwa <- readRDS(paste0("data/KIWA_data_gescraped_", format(Sys.Date(), "%d-%m-%Y"),".rds", sep=""))


#Data ophalen uit storage account
blob_endp <- blob_endpoint("https://rgomwbdscodiag.blob.core.windows.net", 
                           key="RSvNvCZtNm0VjNXez8CqnA/gAd8KjsQRxWlOxmNJxGGUY5PHhdjjvhHZLepzd5I4gGLTfxHgBbVN7xC/sM+r5Q==")
klachtendata_cont <- blob_endp %>% blob_container("klachtendata")
klachtendata_df <- storage_read_csv2(klachtendata_cont, "samen_test.csv")# %>% 
  mutate(Datum = substring(klachtendata_df$DatumTijdMelding,1,10),
         Datum = as.Date(Datum, format = "%Y-%m-%d")) %>% 
           relocate(Datum)



#Dashboard update datum is de datum van vandaag, die wordt dus opgehaald als het script draait
Updatedashboarddatum <- format(Sys.Date(), "%d-%m-%Y")
Scrapedatum <- max(klachtendata_df$Datum) %>% format("%d-%m-%Y")

# UI
ui <- fluidPage(
  titlePanel("Test app"),
  h1(paste0("Dit dashboard is voor het laatst geupdate op ", Updatedashboarddatum, sep="")),
  h2(paste0("De KIWA data is voor het laatst geupdate op ", Scrapedatum, sep="")), 
  DT::dataTableOutput("summary"))

# SERVER
server <- function(input, output) {
  output$summary <- DT::renderDataTable(klachtendata_df)                                           
  
}

print(paste0(Sys.Date(), ": Dit script heeft gerund", sep=""))

# Run the application 
shinyApp(ui = ui, server = server)

