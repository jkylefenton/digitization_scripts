#! /bin/bash

# Crude script to check if files successfully published 
# from i2s LIMB to the staging area
# (esp. check that PDF made it)

cd /mnt/lsdi2/ftp

for i in `find . -type d -mtime -1 -name ALTO`

do 

kdip=${i/\/ALTO/}

#
# Check if the PDF made it to staging
#

pdf=`find ${kdip}/PDF -type f -name "*.pdf"`
if [ -z "$pdf" ]; then 
  echo "No PDF in ${kdip}" | tee -a check_ftp_files.txt
fi

#
# Check if the TIFFs came out bitonal by mistake
#

cntr="0"
tifcnt=`ls ${kdip}/TIFF/*.tif | wc -l`
for file in `ls ${kdip}/TIFF/*.tif`; do 
  value=`exiftool ${file} | grep "Bits Per Sample" | awk -F': ' '{ print $2 }'`
    if [ "$value" != "1" ]; then 
      let cntr+=1
    fi
done

if [ "$tifcnt" -ne "$cntr" ]; then 
  echo "TIFFs for ${kdip} were output as Bitonal" | tee -a check_ftp_files.txt
fi

done

if [ -e check_ftp_files.txt ]; then

#cat check_ftp_files.txt | mail -s "LIMB Publishing Report PROBLEMS FOUND" kyle.fenton@emory.edu
cat check_ftp_files.txt | mail -s "LIMB Publishing Report PROBLEMS FOUND" -c kyle.fenton@emory.edu bwoolge@emory.edu
sleep 1
rm check_ftp_files.txt

else

#echo "No problems from yesterday" | mail -s "LIMB Publishing Report" kyle.fenton@emory.edu
echo "No problems from yesterday" | mail -s "LIMB Publishing Report" -c kyle.fenton@emory.edu bwoolge@emory.edu

fi
