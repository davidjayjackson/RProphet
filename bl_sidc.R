## Aurhor: Ben Letham (bletham@fb.com)
## Organization: Facebook
## Package: Prophet(Time Series)
## Data: Solar Influences Data analysis Center(http://sidc.be)
## Date: 2019-05-31
## Purpose: To combine Sunspots data and R + Prophet(ML) to predict Sunspots/Miniumim activity.
## Challenge: Is  to take into account 11 year solor mim/max cycles
## Documentions: 
## https://facebook.github.io/prophet/docs/seasonality,_holiday_effects,_and_regressors.html#specifying-custom-seasonalities
##
library(data.table)
library(ggplot2)
library(prophet)
library(RSQLite)
library(plotly)
## 
rm(list=ls())
##
## Set Working Directory
## setwd('c:/Users/davidjayjackson/Documents/GitHub/Emacs/')
## Download latest data from SIDC
sidc <-fread("http://sidc.be/silso/DATA/SN_d_tot_V2.0.csv",sep = ';')
colnames(sidc) <- c("Year","Month","Day", "Fdate","Spots", "Sd","Obs" ,"Defin"  )
sidc$Ymd <- as.Date(paste(sidc$Year, sidc$Month, sidc$Day, sep = "-"))
sidc$Spots <- ifelse(sidc$Spots == -1, NA,sidc$Spots)         
##
db <- dbConnect(SQLite(), dbname="../db/solar.sqlite3")
sidc$Ymd <- as.character(sidc$Ymd)
dbWriteTable(db,"sidc",sidc, row.names=FALSE,overwrite=TRUE)
sidc$Ymd <- as.Date(sidc$Ymd)
##
df<-sidc[ ,.(Ymd,Spots)]
colnames(df) <- c("ds","y")
## data <-sidc
## Beginning of Ben's Prophet code
##
m <- prophet(seasonality.mode="multiplicative")
m <- add_seasonality(m, name="cycle_11year", period=365.25 * 11,fourier.order=5)
m <- fit.prophet(m, df)
future <- make_future_dataframe(m,periods=4000,freq="day")
forecast <- predict(m, future)
plot(m, forecast) +ggtitle("SIDC Sunspot Prediction: Jan. 1810 - May. 2030")
forecast <- as.data.table(forecast)
## Current Mininum: 2014 - 2019
forecast1 <- forecast[ds <="1900-01-01",]
ggplot(data=forecast,aes(x=ds,y=yhat)) +geom_line() + geom_smooth() +
  ggtitle("SIDC Current Mimimum: 1810 - 1900")


forecast$ds <- as.character(forecast$ds)
dbWriteTable(db,"blsidc",forecast, row.names=FALSE,overwrite=TRUE)
df$ds <- as.character(df$ds)

dbListTables(db)
