#! /bin/bash

# In Adobe Lightroom 4, if you export an image at the same resolution as the original, 
# the software incorrectly tags the exported image, usually as 240 dpi
# This script reads the X Resolution from the ARCHival master image, and
# copies that value into the PRODuction master image.
# Works recursively, based on Emory's file naming and folder structure
# conventions.

basepath=$1

for arch in `find ${basepath} -type f -iname *_ARCH.tif` 
  do 
#  echo -en "${arch}\t" 
  echo -en "${arch##*/}\t" 
  axres=`exiftool ${arch} | grep "X Resolution" | awk -F':' '{ print $2 }' | tr -d ' '` 
  echo -en "${axres}\t"  
#  prod=`echo ${arch} | tr "ARCH" "PROD"` 
revarch=`echo "${arch:6}" | rev`
prod=`echo "fit.DORP${revarch:8}DORP/." | rev`
  if [ -a ${prod} ] 
    then echo -en "${prod##*/}\t" 
      pxres=`exiftool ${prod} | grep "X Resolution" | awk -F':' '{ print $2 }' | tr -d ' '`
      if ! [ "${pxres}" == "${axres}" ] 
        then
          echo -en "${pxres}\t"
          exiftool -XResolution=${axres} -YResolution=${axres} ${prod} -quiet -overwrite_original -preserve 
          echo `exiftool ${prod} | grep "X Resolution" | awk -F':' '{ print $2 }' | tr -d ' '`
        else
          echo -en "${pxres}\t"
          echo "nothing to fix"
      fi
  else
    echo "${prod##*/} doesn't exist"
  fi 
done

