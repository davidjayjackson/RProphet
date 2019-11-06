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
## Observatory Kanzelhöhe for solar and environmental research
rm(list=ls())
##
## Set Working Directory
setwd('c:/Users/davidjayjackson/Documents/GitHub/Emacs/')
## Download latest data from SIDC
kanzel <-fread("../db/kh_spots.csv")
kanzel$Ymd <- as.Date(kanzel$Ymd)
kanzel <- kanzel[,.(Ymd,R)]
knorth <- kanzel[,.(Ymd,Rn)]
ksouth <- kanzel[,.(Ymd,Rs)]
df <- kanzel
 colnames(df) <- c("ds","y")
colnames(knorth) <- c("ds","y")
colnames(ksouth) <- c("ds","y")
dfS <- knorth
dfS <- ksouth
## Complete Sunspot prediction: 1945 - 2019
## Begin Calc for Knazel  Northern Hempishere sunspots
comp<- prophet(seasonality.mode="multiplicative")
comp <- add_seasonality(comp, name="cycle_11year", period=365.25 * 11,fourier.order=5)
comp<- fit.prophet(comp, df)
future <- make_future_dataframe(north,periods=2000,freq="day")
forecast <- predict(north, future)
forecast <- as.data.table(forecast)
forecast <- forecast[ds >="2014-01-01",]
# ggplot(data=forecast,aes(x=ds,y=yhat)) + geom_line() +geom_smooth() +
#   ggtitle("Kanzel Northern Sunspot Prediction: Jan.1 2014 - May 31, 2019")

## Begin Calc for Knazel  Northern Hempishere sunspots
north <- prophet(seasonality.mode="multiplicative")
north <- add_seasonality(north, name="cycle_11year", period=365.25 * 11,fourier.order=5)
north <- fit.prophet(north, df)
future <- make_future_dataframe(north,periods=2000,freq="day")
forecast <- predict(north, future)
forecast <- as.data.table(forecast)
forecast <- forecast[ds >="2014-01-01",]
ggplot(data=forecast,aes(x=ds,y=yhat)) + geom_line() +geom_smooth() +
  ggtitle("Kanzel Northern Sunspot Prediction: Jan.1 2014 - May 31, 2019")
# plot(north, forecast) +ggtitle("kanzel North Hemisphere: Jan. 1945 - May. 2019")
#
# Begin Calc for Knazel Southern Hempisphere sunspots
south <- prophet(seasonality.mode="multiplicative")
south <- add_seasonality(south, name="cycle_11year", period=365.25 * 11,fourier.order=5)
south <- fit.prophet(south, df1)
Sfuture <- make_future_dataframes(south,periods=2000,freq="day")
Sforecast <- predict(south, Sfuture)
Sforecast <- as.data.table(Sforecast)
Sforecast <- forecast[ds >="2014-01-01",]
ggplot(data=Sforecast,aes(x=ds,y=yhat)) + geom_line() +geom_smooth() +
  ggtitle("Kanzel Southern Hempisphere: Jan. 1,2014 - May 31,2019")
# plot(south, forecast) +ggtitle("kanzel South Hemisphere: Jan. 1945 - May. 2019")

# ## Update sidc (sqlite3) database
# db <- dbConnect(SQLite(), dbname="../db/solar.sqlite3")
# forecast$ds <- as.character(forecast$ds)
# dbWriteTable(db,"blsidc",forecast, row.names=FALSE,overwrite=TRUE)
# dbWriteTable(db,"m",m, row.names=FALSE,overwrite=TRUE)
# dbListTables(db)
