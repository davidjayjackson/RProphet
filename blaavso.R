## Aurhor: Ben Letham (bletham@fb.com)
## Organization: Facebook
## Package: Prophet( Michine Learning)
## Data: http://sidc.be
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
## 
rm(list=ls())
##
## Set Working Directory
setwd('c:/Users/davidjayjackson/Documents/GitHub/Emacs/')
## Download latest data from SIDC
df <-fread("./Data/aavso.csv")
# y = Ra in AAVSO lingo
colnames(df) <- c("Year","Month","Day", "y"  )
df$ds <- as.Date(paste(df$Year, df$Month, df$Day, sep = "-"))
# df<-df[ds>="1945-01-01" & ds <="2019-04-31",.(ds,Spots),]
df <-df[ds >="1945-01-01" & ds <="2019-04-30",.(ds,y),]
summary(df)
## Cteate main data table for : AAVSO Sunspot data
db <- dbConnect(SQLite(), dbname="../db/solar.sqlite3")
df$ds <- as.character(df$ds)
dbWriteTable(db,"aavso",df, row.names=FALSE,overwrite=TRUE)
dbListTables(db)

##
## Beginning of Ben's Prophet code
##
m <- prophet(seasonality.mode="multiplicative")
m <- add_seasonality(m, name="cycle_11year", period=365.25 * 11,fourier.order=5)
m <- fit.prophet(m, df)
future <- make_future_dataframe(m,periods=2000,freq="day")
forecast <- predict(m, future)
plot(m, forecast)
## Update kanzel (sqlite3) database
# db <- dbConnect(SQLite(), dbname="../db/solar.sqlite3")
forecast$ds <- as.character(forecast$ds)
dbWriteTable(db,"blaavso",forecast, row.names=FALSE,overwrite=TRUE)
dbListTables(db)
