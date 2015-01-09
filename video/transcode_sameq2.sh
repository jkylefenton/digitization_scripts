#!/bin/bash

suff[1]="mov"
suff[2]="dv"
suff[3]="avi"
suff[4]="mpg"


for index in 4; do

  for i in $( ls $1.${suff[index]} ); do

#    if [ -e $i.md5 ]; then
#      echo "MD5 checksum for $i already exists"
#    else
#      echo "Generating MD5 for $i"
#      md5sum $i | awk '{ print $1 }' > $i.md5
#      echo "MD5 generated"
#    fi

    if [ -e `basename $i .${suff[index]}`_2.mp4 ]; then
      echo "MPEG4 (2) for $i already exists"
    else
      echo "Transcoding $i"
      ffmpeg -i $i -an -pass 1 -vcodec libx264 -b 6500k -r 29.97 -flags +loop -cmp +chroma -partitions 0 -me_method epzs -subq 1 -trellis 0 -refs 1 -coder 0 -me_range 16 -g 250 -keyint_min 25 -sc_threshold 40 -i_qfactor 0.71 -bt 512k -maxrate 8000k -bufsize 2M -rc_eq 'blurCplx^(1-qComp)' -qcomp 0.6 -qmin 10 -qmax 51 -qdiff 4 -level 13 -deinterlace -y -f mp4 `basename $i .${suff[index]}`_2.mp4
      ffmpeg -i $i -acodec libfaac -ab 128k -async 1 -pass 2 -vcodec libx264 -b 6500k -r 29.97 -flags +loop -cmp +chroma -partitions +parti4x4+partp4x4+partp8x8+partb8x8 -flags2 +mixed_refs -me_method umh -subq 7 -trellis 2 -refs 5 -coder 0 -me_range 16 -g 250 -keyint_min 25 -sc_threshold 40 -i_qfactor 0.71 -bt 512k -maxrate 8000k -bufsize 2M -rc_eq 'blurCplx^(1-qComp)' -qcomp 0.6 -qmin 10 -qmax 51 -qdiff 4 -level 13 -deinterlace -y -f mp4 `basename $i .${suff[index]}`_2.mp4
      echo "Finished transcoding $i"
    fi

  done

done
