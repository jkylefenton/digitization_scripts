#!/bin/bash

suff[5]="iso"

for index in 5; do

  for i in $( ls *.${suff[index]} ); do

    if [ -e $i.md5 ]; then
      echo "MD5 checksum for $i already exists"
    else
      echo "Generating MD5 for $i"
      md5sum $i | awk '{ print $1 }' > $i.md5
      echo "MD5 generated"
    fi

    if [ -e `basename $i .${suff[index]}`.mpg ]; then
      echo "MPEG2 for $i already exists"
    else
      echo "Extracting MPEG2 from ISO for $i"
      mount -o loop $i /mnt/isoimage
      if [ -e /mnt/isoimage/VIDEO_TS/VTS_01_1.VOB ]; then
        cat /mnt/isoimage/VIDEO_TS/VTS_01_*.VOB > `basename $i .${suff[index]}`.mpg
        echo "Finished extracting from $i"
      else
        echo "Unable to extract MPEG2 from DVD image (unfamiliar file layout)"
      fi
      umount /mnt/isoimage
    fi

  done

done

