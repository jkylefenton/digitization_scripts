#!/bin/bash

#temporarily change IFS to account for white space in file names
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

basepath="/mnt/lsdi/diesel/lts_new"

echo "Basepath is $basepath "

echo "path|date|size|pages|width(pts)|height(pts)"

#  for i in `find $basepath -type f -iname '\*\*\Output\*.pdf'`; do
find $basepath -type f -iname *\*\Output\*.pdf | while read i
 do
    echo -n $i"|"
    echo -n `ls -g $i | awk '{ print $5 "|" $4 "|"}'` 
    echo -n `pdfinfo $i | grep Pages | awk -F'[: \t\n]+' '{print $2"|"}'`
    echo `pdfinfo $i | grep 'Page size' | awk -F'[:|x| \t\n]+' '{print $3"|"$4}'`

  done

# restore $IFS
IFS=$SAVEIFS
