#install.packages(shiny)
library(shiny)
library(DT)
#library(later)
library(rsconnect)


# Automatische refresh shiny dashboard
rsconnect::setAccountInfo(name='brabantsomgevingsdatalab', 
                          token='2F6C0E2B9FCD3D772A9C02BD8E2E4DBA', 
                          secret='N2Z8LwgkhYB7DMCOXYYPaGJ4levzkNs9ue/9nXS1')

rsconnect::deployApp(appDir = "C:/Users/omwekr02/Documents/Scrapen_scheduled_tasks/Test_dashboard/Test_app_EK", 
                     appName = 'Test_app_EK',
                     account = 'brabantsomgevingsdatalab',
                     launch.browser = T, forceUpdate = T)

print(paste0(Sys.Date(), ": Dit dashboard is geupdate", sep=""))

