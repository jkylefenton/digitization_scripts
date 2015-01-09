#!/bin/bash

# base paths to check for new video masters to transcode and checksum
# path[1]="/mnt/dm/preservation/spec_col"
# path[2]="/mnt/dm/preservation/univ_arch"
 
# file formats used currently and historically as video masters
suff[1]="mov"
suff[2]="dv"
suff[3]="mpg"
suff[4]="avi"

for index in 1 2 3 4; do

  # loop through all master video files in SERxxxx or MSSxxxx folders under each basepath

#  for i in $( find ${path[index]} -type f -iname *.${suff[index]} | egrep 'SER|MSS' ); do
  for i in $( find /home/jfenton/Desktop/isom_video -type f -iname *.${suff[index]} ); do

    if [ -e $i.md5 ]; then
      echo "MD5 checksum for $i already exists"
    else
      echo "Generating MD5 for $i"
      md5sum $i | awk '{ print $1 }' > $i.md5
      echo "MD5 generated"
    fi

    if [ -e `dirname $i`/`basename $i .${suff[index]}`.mp4 ]; then
      echo "MPEG4 for $i already exists"
    else
      echo "Transcoding $i"
      avconv -i $i -an -pass 1 -vcodec libx264 -b 512k -r 29.97 -flags +loop -cmp +chroma -partitions 0 -me_method epzs -subq 1 -trellis 0 -refs 1 -coder 0 -me_range 16 -g 300 -keyint_min 25 -sc_threshold 40 -i_qfactor 0.71 -bt 512k -maxrate 768k -bufsize 2M -rc_eq 'blurCplx^(1-qComp)' -qcomp 0.6 -qmin 10 -qmax 51 -qdiff 4 -level 13 -deinterlace -y -f mp4 `dirname $i`/`basename $i .${suff[index]}`.mp4 2>&1
      avconv -i $i -acodec libfaac -ab 128k -async 1 -pass 2 -vcodec libx264 -b 512k -r 29.97 -flags +loop -cmp +chroma -partitions +parti4x4+partp4x4+partp8x8+partb8x8 -flags2 +mixed_refs -me_method umh -subq 7 -trellis 2 -refs 5 -coder 0 -me_range 16 -g 300 -keyint_min 25 -sc_threshold 40 -i_qfactor 0.71 -bt 512k -maxrate 768k -bufsize 2M -rc_eq 'blurCplx^(1-qComp)' -qcomp 0.6 -qmin 10 -qmax 51 -qdiff 4 -level 13 -deinterlace -y -f mp4 `dirname $i`/`basename $i .${suff[index]}`.mp4 2>&1
      echo "Finished transcoding $i"
    fi

    if [ -e ffmpeg2pass-0.log ]; then rm -f fmpeg2pass-0.log; fi
    if [ -e x264_2pass.log ]; then rm -f x264_2pass.log; fi
    if [ -e x264_2pass.log.temp ]; then rm -f x264_2pass.log.temp; fi

  done

done


#COMMENTS

# -g set at 10x source frame rate (30 fps x 10 = 300)
