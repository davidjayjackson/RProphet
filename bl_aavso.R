## Aurhor: Ben Letham (bletham@fb.com)
## Organization: Facebook
## Package: Prophet( Michine Learning)
## Data: http://aavso.org/solar/
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
library(plotly)
library(RSQLite)
library(lubridate)

## 
rm(list=ls())
##
## Set Working Directory
setwd('c:/Users/davidjayjackson/Documents/R/Emacs/')
## Download latest data from SIDC
aavso <-fread("https://www.aavso.org/sites/default/files/solar/NOAAfiles/NOAAdaily.csv")
aavso$Ymd <- as.Date(paste(aavso$Year, aavso$Month, aavso$Day, sep = "-"))
##

db <- dbConnect(SQLite(),dbname="../db/solar.sqlite3")
aavso$Ymd <- as.character(aavso$Ymd)
dbWriteTable(db,"aavso",aavso,overwrite=TRUE)
##
aavso<-aavso[Ymd>="1945-01-01",.(Ymd,Ra),]
df <- aavso
colnames(df) <- c("ds", "y"  )
summary(df)

##
## Beginning of Ben's Prophet code
##
m <- prophet(seasonality.mode="multiplicative")
m <- add_seasonality(m, name="cycle_11year", period=365.25 * 11,fourier.order=5)
m <- fit.prophet(m, df)
future <- make_future_dataframe(m,periods=4000,freq="day")
forecast <- predict(m, future)
plot(m,forecast) +ggtitle("NOAA/AAVSO Sunspot Predictions:1945 - 2025")
##
## Subplot of forecast table: 2014 - 2025
forecast1 <- as.data.table(forecast)
forecast1 <- forecast1[ds >="2014-01-01",]
ggplot(data=forecast1,aes(x=ds,y=yhat)) + geom_line() + geom_smooth() + 
  ggtitle("AAVSO Current Mimimum: 2014 - 2030")
##
library(RSQLite)
db <- dbConnect(SQLite(),dbname="../db/solar.sqlite3")
df$ds <- as.character(df$ds)
dbWriteTable(db,"aavso",df,overwrite=TRUE)
forecast$ds <- as.character(forecast$ds)
dbWriteTable(db, "blaavso",forecast,overwrite=TRUE)
dbListTables(db)
