#!/bin/bash
echo "Enter your ppi for target jpgs and press [ENTER]: "
read ppi
for i in $( ls *.tif ); do
   convert -resample $ppi $i `basename $i .tif`_ppi$ppi.jpg
done
