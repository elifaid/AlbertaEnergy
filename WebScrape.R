library(tidyverse)
library(lubridate)
library(rvest)
library(taskscheduleR)
Create_table <-function (table_num,Energy_type){
  table<-tables[[table_num]]
  names(table) <- as.character(table[1,])
  table <- table[2:nrow(table),]
  table$MC<-as.numeric(table$MC)
  table$TNG<-as.numeric(table$TNG)
  table <- table %>%  filter(!is.na(TNG))
  table$Energy=Energy_type
  return(table)
}

while(TRUE)
{
html_alberta <- read_html("http://ets.aeso.ca/ets_web/ip/Market/Reports/CSDReportServlet")
tables<- html_alberta %>% html_nodes("table") %>% html_table(fill = TRUE)



#7 8 9 Sumamries
#12 Coal
#13 Gas
#15 Hydro
#16 Wind
#17 Biomass and other

Coal<-Create_table(12,"Coal")
#Gas<-Create_table(13,"Gas")
Hydro<-Create_table(15,"Hydro")
Wind<-Create_table(16,"Wind")
Biomass<-Create_table(17,"Biomass")
Last_Update<-sub(".*: ", "",tables[[5]]$X1[2])
Date<-mdy(substr(Last_Update, 1, 12))
Time<-substr(Last_Update, nchar(Last_Update) - 4, nchar(Last_Update))
  
Gas<-tables[[13]] # Doesn;t work in the function because it has 3 lines at the top, I think
names(Gas) <- as.character(Gas[2,])
Gas <- Gas[3:nrow(Gas),]
Gas$MC<-as.numeric(Gas$MC)
Gas$TNG<-as.numeric(Gas$TNG)
Gas$Energy="Gas"
Gas <- Gas %>%  filter(!is.na(TNG)) # Get rid of the sub categories

total<- rbind(Coal,Gas,Hydro,Wind,Biomass) # Combining all the Energy sources together
total$Date=Date 
total$Time=Time
#ggplot(data= total,aes(x=MC,y=TNG))+geom_point()+geom_smooth(method='lm')

# Interchange Table3
Interchange<-tables[[9]]
names(Interchange) <- as.character(Interchange[1,])
Interchange <- Interchange[2:nrow(Interchange),]
Interchange$Date=Date 
Interchange$Time=Time

if( file.exists("Data.csv")){
    write_excel_csv(total,"Data.csv",col_names = FALSE,append = TRUE)
} else write_excel_csv(total,"Data.csv")

if( file.exists("Interchange.csv")){
  write_excel_csv(Interchange,"Interchange.csv",col_names = FALSE,append = TRUE)
} else write_excel_csv(Interchange,"Interchange.csv")

    Sys.sleep(120) #basically sleep for whatever is left of the second
}
