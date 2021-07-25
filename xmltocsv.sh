!/usr/bin/bash
# file_name.txt file contains the date for which we have the data available.
# After unzippng the main file which contins all the other zip files, are placed 
# into /mnt/hgfs/ais-data_processing/data/ folder. These all other zip files contains
# zipped files of hourly data starting from 00:00:00 HRS to 23:59:59 HRS of a day.
# Looping through all entries in file_name.txt
for rc in `cat file_name.txt`
do
# Picking up all the zipped files for a single day
  file_path='/mnt/hgfs/ais-data_processing/data/'$rc'*.zip'
# coping the files into current directory
  cp $file_path .
# Creating name of the file    
  final_csv="combine_"$rc".csv"
# Inserting header
  echo 'MMSI,TIME,LATITUDE,LONGITUDE,COG,SOG,HEADING,ROT,NAVSTAT,IMO,NAME,CALLSIGN,TYPE,A,B,C,D,DRAUGHT,DEST,ETA' > $final_csv
# Looping through all the files whic are copied in current directory  
  for i in `ls *.zip`
  do
# Unzipping a zipped XML file    
	unzip $i
# Chaking whether the unzipping was successful 	
    if [ $? -eq 0 ]
    then
# Assigning the name of the csv file that will hold the parsed XML data from unzipped XML file	
	csvfile_name=`echo $i | cut -d'.' -f1`".csv"
# Assigning the XML file name
    xmlfilename=`ls *.xml`
# Calling the R script to parse the XML file.	
    Rscript xmltocsv.R $xmlfilename $csvfile_name
# Removing the header from the processed csv file.	
    sed -i 1d $csvfile_name
    fi
# Removing the unzipped XML file	
    rm *.xml
# Coping the data in the processed CSV file to another CSV file which will hold data for a particular day.	
    cat $csvfile_name >> $final_csv
  done
# Moving the day basis CSV file to another folder  
  mv $final_csv /mnt/hgfs/ais-data_processing/resultant

# Removing all the remaining CSV and ZIP files from current directory.  
  all_csv=$rc'*.csv'
  all_zip=$rc'*.zip'
  rm $all_csv
  rm $all_zip
done