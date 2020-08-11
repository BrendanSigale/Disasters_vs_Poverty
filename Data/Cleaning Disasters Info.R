## Cleaning Poverty Info

library(dplyr)
library(cdlTools)
library(reshape2)

df <- read.csv("OpenFemaDataSets.csv", stringsAsFactors = FALSE)

dfCols <- c("state", "declarationDate", "fyDeclared", "disasterType", "disasterCloseOutDate", "placeCode")

df<- df[,dfCols]

names(df) <- c("year", "region", "pctPoverty", "medianIncome")

df$length <- as.Date(df$disasterCloseOutDate)-as.Date(df$declarationDate)

df$disasterCloseOutDate <- NULL
df$declarationDate <- NULL
df$disasterType <- NULL
df <- df[complete.cases(df),]
df$placeCode <- substr(df$placeCode, 3, nchar(df$placeCode))

df$StateCode <- fips(df$state, to="FIPS")

df$region <- paste(df$StateCode, df$placeCode, sep="")

df$placeCode <- NULL
df$StateCode <- NULL
df$state <- NULL

ifelse(nchar(df$region) == 4, df$region <- paste("0", df$region, sep=""), df$region <- df$region)

##for(i in 1953:2017) {
  tmpdf <- subset(df, fyDeclared==i)
  write.csv(tmpdf, file = paste("Disasters In ", i, ".csv", sep = ''))
}

df <- subset(df, fyDeclared>1988)
## Grouped by region, averages over all years in dataset.
df <- df[complete.cases(df),]
df <- group_by(df, region)

dfSumm <- summarize(df,
                    avgLength = mean(length))
dfCast <- dcast(df, region ~ length, value.var = "length", fun.aggregate = sum)

write.csv(dfSumm, file="AverageDisastersByCounty.csv")
