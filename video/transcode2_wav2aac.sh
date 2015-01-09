#!/bin/bash

path[1]="/mnt/dm/preservation/spec_col"
path[2]="/mnt/dm/preservation/univ_arch"

for index in 1 2; do

for i in $( find ${path[index]} -type f -iname *.wav | egrep 'SER|MSS|Danowski' ); do

  if [ -e $i.md5 ]; then
    echo > /dev/null
#    echo "MD5 checksum for $i already exists"
  else
    echo "Generating MD5 for $i"
    md5sum $i | awk '{ print $1 }' > $i.md5
    echo "MD5 generated"
  fi

  if [ -e $i.jhove ]; then
    echo > /dev/null
#    echo "JHOVE file for $i already exists"
  else
    echo "File valid and well formed?"
    /usr/local/bin/jhove/jhove -c /usr/local/bin/jhove/conf/jhove.conf -m WAVE-hul -h audit $i | grep status
    echo "Generating JHOVE for $i"
    /usr/local/bin/jhove/jhove -c /usr/local/bin/jhove/conf/jhove.conf -m WAVE-hul -kr -h xml $i > $i.jhove
    echo "Finished generating JHOVE file"
  fi

  if [ -e `dirname $i`/`basename $i .wav`.m4a ]; then
    echo > /dev/null
#    echo "MPEG4 for $i already exists"
  else
    echo "Transcoding $i"
    /home/jfenton/nero/linux/neroAacEnc -cbr 320000 -if $i -of `dirname $i`/`basename $i .wav`.m4a
    echo "Finished transcoding $i"
  fi

done

done
