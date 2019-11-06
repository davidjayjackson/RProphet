## Aurhor: Ben Letham (bletham@fb.com)
## Organization: Facebook
## Package: Prophet Michine Learning
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
df <-fread("./Data/bremen.csv")
str(df)
colnames(df) <- c("ds","y","Uncert", "Source" )
df$ds <- as.Date(df$ds)
df<-df[ ds <="2019-01-01",.(ds,y),]
summary(df)
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
db <- dbConnect(SQLite(), dbname="../db/kanzel.sqlite3")
forecast$ds <- as.character(forecast$ds)
dbWriteTable(db,"prophet",forecast, row.names=FALSE,overwrite=TRUE)
dbListTables(db)
