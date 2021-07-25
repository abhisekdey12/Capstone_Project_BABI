#setwd("/mnt/hgfs/abcd1/experiment")
library(XML)
arguments <-commandArgs(trailingOnly = TRUE)
xml_file_name <- arguments[1]
csv_file_name <- arguments[2]
rootnode <-xmlRoot(xmlParse(xml_file_name))
dfinal2<-data.frame(xpathSApply(rootnode,"//vessel",xmlGetAttr, "MMSI"),
                    xpathSApply(rootnode,"//vessel",xmlGetAttr, "TIME"),
                    xpathSApply(rootnode,"//vessel",xmlGetAttr, "LATITUDE"),
                    xpathSApply(rootnode,"//vessel",xmlGetAttr, "LONGITUDE"),
                    xpathSApply(rootnode,"//vessel",xmlGetAttr, "COG"),
                    xpathSApply(rootnode,"//vessel",xmlGetAttr, "SOG"),
                    xpathSApply(rootnode,"//vessel",xmlGetAttr, "HEADING"),
                    xpathSApply(rootnode,"//vessel",xmlGetAttr, "ROT"),
                    xpathSApply(rootnode,"//vessel",xmlGetAttr, "NAVSTAT"),
                    xpathSApply(rootnode,"//vessel",xmlGetAttr, "IMO"),
                    xpathSApply(rootnode,"//vessel",xmlGetAttr, "NAME"),
                    xpathSApply(rootnode,"//vessel",xmlGetAttr, "CALLSIGN"),
                    xpathSApply(rootnode,"//vessel",xmlGetAttr, "TYPE"),
                    xpathSApply(rootnode,"//vessel",xmlGetAttr, "A"),
                    xpathSApply(rootnode,"//vessel",xmlGetAttr, "B"),
                    xpathSApply(rootnode,"//vessel",xmlGetAttr, "C"),
                    xpathSApply(rootnode,"//vessel",xmlGetAttr, "D"),
                    xpathSApply(rootnode,"//vessel",xmlGetAttr, "DRAUGHT"),
                    xpathSApply(rootnode,"//vessel",xmlGetAttr, "DEST"),
                    xpathSApply(rootnode,"//vessel",xmlGetAttr, "ETA")
)

names(dfinal2) <- c("MMSI","TIME","LATITUDE","LONGITUDE","COG","SOG","HEADING","ROT","NAVSTAT","IMO","NAME","CALLSIGN","TYPE","A","B","C","D","DRAUGHT","DEST","ETA")
write.csv(dfinal2,csv_file_name,row.names = FALSE)
