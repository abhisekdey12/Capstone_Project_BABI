#Notes
#1) 3479 - no data
library(XML)
xml_file_path='D:/Capstone/xml_files'
csv_file_path='D:/Capstone/csv_files'
squence=seq(4361,4366,1) #4366
filename='data'
d1=Sys.time()
for(i in squence)
{
  xml_file_name=paste(xml_file_path,'/',filename,'_',i,'.xml',sep = "")
  rootnode = xmlRoot(xmlParse(xml_file_name))
  dfinal2<-data.frame(xpathSApply(rootnode,"//vessel",xmlGetAttr, "MMSI"),
                      xpathSApply(rootnode,"//vessel",xmlGetAttr, "TIME"),
                      xpathSApply(rootnode,"//vessel",xmlGetAttr, "LONGITUDE"),
                      xpathSApply(rootnode,"//vessel",xmlGetAttr, "LATITUDE"),
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
  names(dfinal2) <- c("MMSI","TIME","LONGITUDE","LATITUDE","COG","SOG","HEADING","ROT","NAVSTAT","IMO","NAME","CALLSIGN","TYPE","A","B","C","D","DRAUGHT","DEST","ETA")
  print(i)
  csv_file_name=paste(csv_file_path,'/',filename,'_',i,'.csv',sep = "")
  write.csv(dfinal2,csv_file_name,row.names = FALSE)
  remove(dfinal2)
}

d2=Sys.time()
diff=d2-d1
print(diff)
