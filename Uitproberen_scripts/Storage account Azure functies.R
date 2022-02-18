#### 0. Set-up --------------------------------------------------------------------------------------------------------------
library(tidyverse)
library(AzureStor)
library(AzureRMR)
#AzureRMR: Interface to 'Azure Resource Manager'
#A lightweight but powerful R interface to the 'Azure Resource Manager' REST API. 
#The package exposes a comprehensive class framework and related tools for creating, updating and deleting 'Azure' resource groups, resources 
#and templates. While 'AzureRMR' can be used to manage any 'Azure' service, 
#it can also be extended by other packages to provide extra functionality for specific services. Part of the 'AzureR' family of packages.

#### 1. Connect to Storage account and create endpoint  --------------------------------------------------------------------------------------------------------------
blob_endp <- blob_endpoint("https://rgomwbdscodiag.blob.core.windows.net", 
                         key="RSvNvCZtNm0VjNXez8CqnA/gAd8KjsQRxWlOxmNJxGGUY5PHhdjjvhHZLepzd5I4gGLTfxHgBbVN7xC/sM+r5Q==")
print(blob_endp)


#https://blog.revolutionanalytics.com/2018/12/azurestor.html

#Instead of an access key, you can provide a shared access signature (SAS) to gain authenticated access.
#The main difference between using a key and a SAS is that the former unlocks access to the entire storage account.
#A user who has a key can access all containers and files, and can read, modify and delete data without restriction.
#On the other hand, a user with a SAS can be limited to have access only to specific files, or be limited to read access, 
#or only for a given span of time, and so on. This is usually much better in terms of security


#### 2. Interact with storage account  --------------------------------------------------------------------------------------------------------------

#Given an endpoint object, AzureStor provides the following methods for working with containers:
  
# blob_container: get an existing blob container
    # list_blobs(cont): list blobs inside a blob container - info="name" add if you only want the filenames
# create_blob_container: create a new blob container
# delete_blob_container: delete a blob container
# list_blob_containers: return a list of blob container objects

## Inlezen welke blob containers er allemaal zijn, boot diagnostics niet aankomen
containers <- blob_endp %>% list_blob_containers()
containers
## Aanmaken van een nieuwe container
#Let op: voor het aanmaken van een nieuwe container moet je de code wel ergens aan toe schrijven
#newcontainer <- blob_endp %>% create_blob_container("klachtendata")
#delete_blob_container(newcontainer)


## Inlezen van een bestaande container
klachtendata_cont <- blob_endp %>% blob_container("klachtendata") 
klachtendata_cont
list_blobs(klachtendata_cont)
           
## Ophalen van csv uit azure storage account
## CSV2 werkt voor bestanden met semi-colon separator, csv voor bestanden met comma separator
klachtendata_df <- storage_read_csv(klachtendata_cont, "test/Lijst RVO silo's inclusief coordinaten.csv")

library(tidyverse)
klachtendata_df_mutate <- klachtendata_df %>% mutate(Test = "Nieuwe kolom toegevoegd")


#Terugschrijven van csv naar azure storage account
storage_write_csv(klachtendata_df_mutate, klachtendata_cont, "test/Lijst RVO silo's inclusief coordinaten_mutate.csv")


groot <- storage_read_csv(klachtendata_cont,"test/12. Overzicht meldingen Brabant december 2020 - origineel.csv")

