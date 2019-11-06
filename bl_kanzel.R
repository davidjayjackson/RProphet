## Aurhor: Ben Letham (bletham@fb.com)
## Organization: Facebook
## Package: Prophet Michine Learning
## Data: 
## Date: 2019-05-31
## Purpose: To combine Sunspots data and R + Prophet(ML) to predict Sunspots/Miniumim activity.
## Challenge: Was to take into account 11 year solor mim/max cycles
## Documentions: 
## https://facebook.github.io/prophet/docs/seasonality,_holiday_effects,_and_regressors.html#specifying-custom-seasonalities
## My data import and cleaning code:
##
library(data.table)
library(ggplot2)
library(prophet)
library(RSQLite)
library(plotly)
db <- dbConnect(SQLite(), dbname="../db/solar.sqlite3")
## Observatory Kanzelhöhe for solar and environmental research
rm(list=ls())
##
## Set Working Directory
## setwd('c:/Users/davidjayjackson/Documents/GitHub/Emacs/')
## Download latest data from SIDC
kanzel <-fread("../db/kh_spots.csv")
kanzel$G <- kanzel$g_n + kanzel$g_s
## kanzel$Ymd <- as.Date(kanzel$Ymd)
kanzel$Ymd <- as.character(kanzel$Ymd)
dbWriteTable(db,"kanzel",kanzel, row.names=FALSE,overwrite=TRUE)
kanzel$Ymd <- as.Date(kanzel$Ymd)
kanzel <- kanzel[,.(Ymd,g_s)]
df <- kanzel
colnames(df) <- c("ds","y")
##
m <- prophet(seasonality.mode="multiplicative")
m <- add_seasonality(m, name="cycle_11year", period=365.25 * 11,fourier.order=5)
m <- fit.prophet(m, df)
future <- make_future_dataframe(m,periods=8000,freq="day")
forecast <- predict(m, future)
plot(m,forecast) +ggtitle("Kanzel South Predictions:1945 - 2025")
## Complete Sunspot prediction: 1945 - 2019
## Begin Calc for Knazel  Northern Hempishere sunspots
forecast$ds <- as.Date(forecast$ds)
forecast <- as.data.table(forecast)
forecast1 <- forecast[ds >="2014-01-01",]
p <- ggplot(data=forecast1,aes(x=ds,y=yhat)) + geom_line() +geom_smooth() +
   ggtitle("Kanzel Current Min. Prediction: Jan.1 2014 - June 2019")
ggplotly(p)

forecast <- as.data.table(forecast)
forecast$ds <- as.Date(forecast$ds)
s <-forecast[,.(ds,yhat)]
colnames(s) <-c("Ymd","South")
kgroups <- merge(n,s,by="Ymd")
k <- kgroups[Ymd >="2014-01-01",]
ggplot(data=k,aes(x=Ymd,y=North,col="North")) + geom_line() + geom_line(data=k,aes(x=Ymd,y=South,col="South"))
##
# ## Update sidc (sqlite3) database
db <- dbConnect(SQLite(), dbname="../db/solar.sqlite3")
forecast$ds <- as.character(forecast$ds)
dbWriteTable(db,"blkanzel",forecast, row.names=FALSE,overwrite=TRUE)
kanzel$ds <- as.character(kanzel$ds)
dbWriteTable(db,"kanzel",kanzel, row.names=FALSE,overwrite=TRUE)
dbListTables(db)
