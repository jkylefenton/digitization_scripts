#!/bin/bash

#temporarily change IFS to account for white space in file names
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

suff[1]="mov"
suff[2]="mpg"
suff[3]="avi"
suff[4]="dv"
suff[5]="wav"
suff[6]="tif"
suff[7]="tiff"
suff[8]="TIF"
suff[9]="TIFF"

basepath="/mnt/dm/marbl"

 echo "Basepath is $basepath "
 echo "Enter start date [YYYY-MM-DD] "
 read startdate
 echo "Enter end date [YYYY-MM-DD] "
 read enddate
 echo "Will find files between $startdate and $enddate"

 touch -d $startdate getstats_oldfile
 touch -d $enddate getstats_newfile

echo "path|date|size|hr|min|sec"

# for index in 1 2 3 4; do
# for index in 5; do
for index in 6 7 8 9; do

  for i in $( find $basepath -iname \*.${suff[index]} -newer getstats_oldfile ! -newer getstats_newfile | grep -v '\.\_' ); do

    echo -n $i"|"
    echo -n `ls -g $i | awk '{ print $7 "|" $5 "|" $4 }'`
    echo
#    ffmpeg -i $i -f null 2>&1 | grep Duration | awk -F'[:|,| \t\n]+' '{ print $3":"$4":"$5 }'    

  done

done

# restore $IFS
IFS=$SAVEIFS
