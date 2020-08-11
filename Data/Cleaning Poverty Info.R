## Cleaning Poverty Info

library(dplyr)

df <- read.csv("medianIncomeUS.csv", stringsAsFactors = FALSE)


##Cleaning
dfCols <- c("Year", "County.ID", "All.Ages.in.Poverty.Percent", "Median.Household.Income.in.Dollars")

df<- df[,dfCols]

names(df) <- c("year", "region", "pctPoverty", "medianIncome")

df$medianIncome <- gsub(",", "",  df$medianIncome)
df$medianIncome <- substr(df$medianIncome, 2, nchar(df$medianIncome))

df$medianIncome <- as.numeric(df$medianIncome)

##Separated by Year
path_out <- "./DataByYear"
for(i in 1989:2017) {
  tmpdf <- subset(df, year==i)
  write.csv(tmpdf, file = paste(path_out, i, ".csv", sep = ''), )
}


## Grouped by region, averages over all years in dataset.
df <- df[complete.cases(df),]
df <- group_by(df, region)

dfSumm <- summarize(df,
                    avgPov = mean((pctPoverty)),
                    avgIncome = mean(medianIncome))

write.csv(dfSumm, file="AveragesByCounty.csv")
