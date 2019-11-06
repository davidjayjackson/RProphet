library(data.table)
library(forecast)
library(ggplot2)
library(plotly)
library(xts)
library(lubridate)
library(RSQLite)
library(AutoModel)

rm(list=ls())
#
kanzel <- fread("/Users/davidjayjackson/Documents/GitHub/db/kanzel.html")
kanzel$Ymd <- as.Date(kanzel$Ymd)
kanzel$Year <- year(kanzel$Ymd)
kanzel$Month <- month(kanzel$Ymd)
kanzel<-kanzel[,.(Year,Ymd,g_n,s_n,g_s,s_s,R,R_n,R_s)]
## Plots for current mimumnn and Year
current_year<-kanzel[Year>=2019,.(Ymd,R),]
current_min <- kanzel[Year =2014,.(Ymd,R),]
ggplot(data=current_year,aes(x=Ymd,y=R)) + geom_line() + geom_smooth(method="lm") + geom_smooth(col="red")
ggplot(data=current_min,aes(x=Ymd,y=R)) + geom_line() + geom_smooth(method="lm") + geom_smooth(col="red")

# AutoModel 
## run_model("R", c("g_n", "s_n","g_s", "s_s"), c("R_n", "R_s"), dataset=kanzel)
