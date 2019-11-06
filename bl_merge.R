##  Read db tables from /db/solar.sqlite3
## use R merged functions to create summary table
library(ggplot2)
library(data.table)
library(RSQLite)
library(forecast)
# Pull data:
db <- dbConnect(SQLite(), dbname="../db/solar.sqlite3")
key<- dbGetQuery(db, "SELECT Ymd,Spots  FROM sidc where Year>=1850")
kanzel<- dbGetQuery(db, "SELECT ds,yhat FROM blkanzel")
sidc<- dbGetQuery(db, "SELECT ds,yhat FROM blsidc")
aavso<- dbGetQuery(db, "SELECT ds,yhat FROM  blaavso")
##
key <- as.data.table(key)
kanzel <- as.data.table(kanzel)
sidc <- as.data.table(sidc)
aavso <- as.data.table(aavso)
## change col names:
colnames(key) <- c("Ymd","Sidc")
colnames(kanzel)  <-c("Ymd","kanzel")
colnames(sidc) <- c("Ymd","sidc")
colnames(aavso) <- c("Ymd","aavso")
## Convert date field to Date format
key$Ymd <-as.Date(key$Ymd)
kanzel$Ymd <- as.Date(kanzel$Ymd)
sidc$Ymd <- as.Date(sidc$Ymd)
aavso$Ymd <- as.Date(aavso$Ymd)
## Begin Merging df.
merged.aa <- merge(key,aavso,all.x=TRUE)
merged.ab <- merge(merged.aa,kanzel,all.x=TRUE)
merged.ab$Ymd <-as.Date(merged.ab$Ymd)
## Write merged table to db
merged.ab$Ymd <-as.character(merged.ab$Ymd)
dbWriteTable(db,"combined",merged.ab, row.names=FALSE,overwrite=TRUE)
dbDiscommect(db)
##
df <- merged.ab[Ymd >="1955-01-01",]
ggplot(df,aes(x=Ymd,y=Sidc)) + geom_bar(stat = "count") 
 
   
    
