library(data.table)
library(forecast)
library(ggplot2)
library(plotly)
library(xts)
library(lubridate)
library(RSQLite)
library(AutoModel)
library(MASS)
library(stats)   # location of the time series modules
# library(graphics)
# library(lattice)
# library(rgl)

rm(list=ls())
#
kanzel <- fread("kanzel.html")
kanzel$Ymd <- as.Date(kanzel$Ymd)
kanzel$Year <- year(kanzel$Ymd)
kanzel$Month <- month(kanzel$Ymd)
kanzel<-kanzel[,.(Ymd,g_n,s_n,g_s,s_s,R,R_n,R_s)]
# AutoModel 
summary (kanzel)

# rename data column names
X <- kanzel
summary(X)
nrow(X)

X$Ymd <- as.character(X$Ymd)
str(X)

#require(MTS)
X$ymd <- as.character(paste(as.character(X$Ymd)))
z <- data.frame(diff(X$R),diff(X$R_n),diff(X$R_s),row.names=X$ymd[-1])
colnames(z) <- c("R","R_n","R_s")
str(z)


run_model("R", c("R"), c("R_n", "R_s"), dataset=z)



# # run_model("R", c("g_n", "s_n","g_s", "s_s"), c("R_n", "R_s"), dataset=kanzel)
