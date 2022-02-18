## --- --------------------- ---
## Script name: Run R script scrapen KIWA automatically
## Author: Esmee Kramer
## Date Created: 25.09.2020
## --- --------------------- ---
## Notes:
##   
##
## --- --------------------- ---


## Libraries laden -----------------------------------------------------------------------
library(taskscheduleR)

## Runnen script automatisch schedulen -----------------------------------------------------------------------
rscript1 = "C:/Users/omwekr02/Documents/Scrapen_scheduled_tasks/Test_dashboard/Test_app_EK/data/Scrapen_KIWA2.R"
taskscheduler_create(taskname = "run_scrapen_KIWA", rscript = rscript1, 
                     schedule = "DAILY", 
                     starttime = "09:05", 
                     startdate = format(Sys.Date()+1, "%d/%m/%Y"))

## Let op: Hierna moet je nog bij de instellingen van de taakplanner instellen dat het script ook runt zonder dat je laptop op batterij
## aangesloten hoeft te worden

rscript1a = "C:/Users/omwekr02/Documents/Scrapen_scheduled_tasks/Test_dashboard/Test_app_EK/data/Scrapen_KIWA2.R"
taskscheduler_create(taskname = "run_scrapen_KIWA", rscript = rscript1a,
                     schedule = "DAILY",
                     starttime = "09:05",
                     startdate = format(Sys.Date()+1, "%d/%m/%Y"))



# There are several options here, including WEEKLY, DAILY, MONTHLY, HOURLY, and MINUTE
# In addition to these arguments, taskscheduler_create also has a parameter called "modifier". This allows us to modify the schedule frequency. 
# For example, what if we want to run the task every 2 hours? In this case, we would just set modifier = 2.

#Bekijken welke taken er nu allemaal in de scheduler staan
tasks <- taskscheduler_ls()
taskscheduler_delete("run_scrapen_KIWA")
taskscheduler_delete("update_test_dashboard")
#taskscheduler_stop("run_scrapen_KIWA")


# rscript2 = "C:/Users/omwekr02/Documents/Scrapen_scheduled_tasks/Test_dashboard/Automatische_update_test_app.R"
# taskscheduler_create(taskname = "update_test_dashboard", rscript = rscript2, 
#                      schedule = "DAILY", 
#                      starttime = "14:2", 
#                      startdate = format(Sys.Date()+1, "%d/%m/%Y"))

rscript2 = "C:/Users/omwekr02/Documents/Scrapen_scheduled_tasks/Test_dashboard/Automatische_update_test_app.R"
taskscheduler_create(taskname = "update_test_dashboard", rscript = rscript2, 
                     schedule = "DAILY", 
                     starttime = "09:15", 
                     startdate = format(Sys.Date(), "%d/%m/%Y"))

