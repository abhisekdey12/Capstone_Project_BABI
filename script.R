library(doParallel)
library(data.table)
library(readr)
library(dplyr)
library(parallel)
library(geosphere)
processedDataPath <- "D:/Capstone/test/"
#  "F:/Capstone Project PGP-BABI/SG/processed_data/"
# filePath is the folder which contains all daily level data files
filePath <- "D:/Capstone/test/"
#  "F:/Capstone Project PGP-BABI/SG/resultant/"

fileExtn <- "*.csv"

filePathnName <- data.frame(unlist(list.files(
  path = filePath,
  pattern = fileExtn,
  full.names = TRUE
)), stringsAsFactors = FALSE)

names(filePathnName) <- "fileName"
n <- 0
for (i in filePathnName$fileName) {
  df <- fread(i, showProgress = FALSE)
  df <- df[df$LATITUDE <= 90,]
  df <- df[df$LATITUDE >= -90,]
  df <- df[df$LONGITUDE <= 180,]
  df <- df[df$LONGITUDE >= -180,]
  df$sglat <- "1.2593655"
  df$sglong <- "103.75445"
  df$dist_from_sg_kmn <-
    distGeo(df[, c("LONGITUDE", "LATITUDE")], df[, c("sglong", "sglat")]) /
    (1000)
  df$is_under_15_NM <-
    if_else(df[, c("dist_from_sg_kmn")] > 27.78, 'N', 'Y')
  dfsg <- df[df$is_under_15_NM == 'Y',]
  fl <-
    paste(processedDataPath,
          "day_processed_data_",
          unlist(strsplit(unlist(strsplit(
            i, "/"
          ))[5], "_"))[3],
          sep = "")
  print(fl)
  write.csv(dfsg, fl, row.names = FALSE)
  if (n == 0) {
    final_df <- dfsg
  } else{
    final_df <- rbind(final_df, dfsg)
  }
  n <- n + 1
  df <- data.frame()
}

final_df$at_port <- 'Z'
final_df$at_port <-
  if_else(final_df[, c("dist_from_sg_kmn")] > 3.5, 'N', 'Y')
final_df <- final_df[final_df$at_port == 'Y', ]
dfz <- data.frame(unique(final_df$MMSI))
final_df <- final_df[order(final_df$TIME)]

#final_df_test <- final_df[final_df$MMSI=='353368000',]

final_df <- final_df[final_df$NAVSTAT %in% c(1, 5), ]
resultant_df <- data.frame()
for (i in unique(final_df$MMSI)) {
  temp_df <- final_df[final_df$MMSI == i, ]
  temp_df <- temp_df[order(temp_df$TIME)]
  temp_df$TIME <-
    as.POSIXct(temp_df$TIME,
               tz = "GMT",
               format = "%Y-%m-%d %H:%M:%S")
  temp_df$BT <- temp_df$TIME
  temp_df$HOUR_DIFF_NEXT_REC <-
    abs(as.numeric(difftime(temp_df$TIME,
                            lead(temp_df$BT),
                            units = "hour")))
  temp_df[is.na(temp_df$HOUR_DIFF_NEXT_REC), ]$HOUR_DIFF_NEXT_REC <-
    0
  temp_df
  ##
  temp_df$NR <-
    if_else(temp_df$HOUR_DIFF_NEXT_REC > 4, 'Y', 'N')
  temp_df$sn <- c(1:nrow(temp_df))
  gt_4_DF <-
    temp_df[temp_df$HOUR_DIFF_NEXT_REC > 4, ]
  minsn <- 1
  if (nrow(gt_4_DF) > 0)
  {
    t_data <- data.frame(temp_df$sn, temp_df$BT)
    names(t_data) <- c("sn", "BT")
    for (j in 1:nrow(gt_4_DF)) {
      gt_4_DF[j, ]$BT <-     t_data[t_data$sn == minsn, ]$BT
      minsn <- gt_4_DF[j, ]$sn + 1
    }
    resultant_df <- rbind(resultant_df, gt_4_DF)
  }
  temp_df$NR <- 'N'
  minsn <-
    ifelse(minsn > nrow(temp_df),
           nrow(temp_df),
           minsn)
  temp_df[nrow(temp_df), ]$BT <-
    temp_df[temp_df$sn == minsn, ]$BT
  temp_df[nrow(temp_df), ]$NR <- 'YN'
  resultant_df <-
    rbind(resultant_df, temp_df[temp_df$NR == 'YN', ])
  resultant_df$NR <- 'Y'
}

write.csv(final_df,
          paste(processedDataPath,
                "data_after_3KM_logic.csv", sep = ""))
write.csv(resultant_df,
          paste(processedDataPath,
                "data_after_4HR_logic.csv", sep = ""))
