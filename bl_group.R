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

## 
rm(list=ls())
##
## Set Working Directory
setwd('c:/Users/davidjayjackson/Documents/R/Emacs/')
## Download latest data from SIDC
aavso <-fread("../db/gndb.csv")
aavso$Day <- 15
aavso$Ymd <- as.Date(paste(aavso$Year, aavso$Month, aavso$Day, sep = "-"))
# aavso<-aavso[Ymd>="1945-01-01",.(Ymd,g),]
df <- aavso
df <- df[,.(Ymd,g)]
colnames(df) <- c("ds", "y"  )
str(df)

##
## Beginning of Ben's Prophet code
##
m <- prophet(seasonality.mode="multiplicative")
m <- add_seasonality(m, name="cycle_11year", period=364.25 * 11,fourier.order=5)
m <- fit.prophet(m, df)
future <- make_future_dataframe(m,periods=12000,freq="day")
forecast <- predict(m, future)
p <-plot(m,forecast) +ggtitle("AAVSO Group Sunspot Predictions:1610 - 2025")
##
## Subplot of forecast table: 2014 - 2025
forecast1 <- as.data.table(forecast)
forecast1 <- forecast1[ds >="1850-01-01",]
p <-ggplot(data=forecast1,aes(x=ds,y=yhat)) + geom_line() + geom_smooth() + 
  ggtitle("AAVSO(Groups) Current Mimimum: 2014 - 2030")
ggplotly(p)
##
library(RSQLite)
db <- dbConnect(SQLite(),dbname="../db/solar.sqlite3")
df$ds <- as.character(df$ds)
dbWriteTable(db,"aavso",df,overwrite=TRUE)
forecast$ds <- as.character(forecast$ds)
dbWriteTable(db, "blaavso",forecast,overwrite=TRUE)
dbListTables(db)
