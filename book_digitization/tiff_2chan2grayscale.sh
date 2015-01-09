#!/bin/bash

# As of Dec 2014, when i2s LIMB software is set to deliver grayscale output, 
# it creates TIF files that are 8 bits per sample and 2 samples per pixel.
# For submission to HathiTrust, we need to convert the native LIMB output to 
# a grayscale TIF that is 8 bits per sample and 1 sample per pixel.

basedir="/mnt/lsdi2/ftp"

volume=$1

bps=`exiftool ${basedir}/${volume}/TIFF/00000001.tif | grep "Bits Per Sample" | awk -F': ' '{ print $2 }'`
if [ "$bps" == "8 8" ]; then
echo "${basedir}/${volume}"
echo $bps
fi
