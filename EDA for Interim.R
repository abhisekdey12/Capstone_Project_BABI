# Loading data

df <- read.csv('E:\\New folder\\Capstone\\data_after_4HR_logic.csv')

# Checking columns

dim(df)

summary(df)

str(df)

# Removing unwanted columns & changing data types

newdf <- df[,-c(1,11,13,20,21,25,26,27,28,29,30)]

str(newdf)

newdf$MMSI <- as.factor(newdf$MMSI)

newdf$NAVSTAT <- as.factor(newdf$NAVSTAT)

newdf$TYPE <- as.factor(newdf$TYPE)                   

library(lubridate)

format <- "%Y-%m-%d"

x <- as.POSIXct(newdf$TIME, format = format, tz = "GMT")

newdf$TIME <- as.Date(x)

# Removing sglat and sglong

newdf <- newdf[, -c(17, 18)]

# Replacing A, B, C, D with a new column "Ship size"

newdf$Ship_size <- newdf$A + newdf$B + newdf$C + newdf$D

newdf <- newdf[, -c(12, 13, 14, 15)]

# Replacing "Ship_size" with Small/med/large/unknown based on the size

size <- function(x) 
  {
  if (x < 100){
    if (x == 0)
    {
      return ("Unknown")
    }
  return ("Small")
  }
    if (x > 200){
      return ("High")
    }
  else{
      return ("Medium")
    }
  }

newdf$Ship_size <- sapply(newdf$Ship_size, size)

newdf$Ship_size <- as.factor(newdf$Ship_size)

# Univariate analysis - numerical variables

hist(newdf$dist_from_sg_kmn)

hist(newdf$DRAUGHT)

hist(newdf$COG)

hist(newdf$SOG)

hist(newdf$HEADING)

hist(newdf$ROT)

boxplot(newdf[, c(5, 6, 7, 8, 12, 13)], horizontal = T)

# Univariate analysis - categorical variables

tab1 <- table(newdf$MMSI)

barplot(tab1, beside = F)

tab2 <- table(newdf$NAVSTAT)

barplot(tab2, beside = F)

tab3 <- table(newdf$TYPE)

barplot(tab3, beside = F)

tab4 <- table(newdf$Ship_size)

barplot(tab4, beside = F)

# Multivariate analysis

library(PerformanceAnalytics)

chart.Correlation(newdf[, c(5, 6, 7, 8, 12, 13)])

# Missing values

sapply(newdf, function(x) sum(is.na(x)))

# Unique MMSI per day for forecasting

agg <- aggregate(data=newdf, newdf$MMSI ~ newdf$TIME, function(x) length(unique(x)))

ddf1 <- write.csv(agg, file = "TS.csv", row.names = F)

