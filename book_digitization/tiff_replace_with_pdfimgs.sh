#!/bin/bash

# Run this script in the root of the KDip to be fixed, i.e. [barcode]

# read in the basepath and cd to the directory

basepath=${PWD}
bc=${PWD##*/}

# check bitdepth of existing tiffs and only proceed if this is a non-full color digitized volume
imagesample2=`find TIFF -name 00000002.tif`
imagebitdepth2=`exiftool $imagesample2 | grep "Bits Per Sample" | awk '{ print $5 }'`

imagesample4=`find TIFF -name 00000004.tif`
imagebitdepth4=`exiftool $imagesample4 | grep "Bits Per Sample" | awk '{ print $5 }'`


if [ $imagebitdepth2 -ne 1 ]; then 
  if [ $imagebitdepth4 -ne 1 ]; then
    echo "${bc} TIFFs are Color -- skipping"
    exit
  fi
fi

# add book path to a log file
# extract images from pdf to subfolder (they will be a mix of jpg, pbm, and ppa)
cd PDF
mkdir EXTRACTED
pdfimages ${bc}.pdf EXTRACTED/
chown -R lsdiftp EXTRACTED
cd EXTRACTED

# remove the leading dash from all extracted image filenames
for file in *; do 
  mv -v -- $file ${file:1}
done

# convert all the images to tiffs
mkdir ../TIFF
for i in *; do 
  convert $i ../TIFF/${i%.*}.tif
done
chown -R lsdiftp ../TIFF

# rename all the converted tiffs to padded with zeroes to 8 places
cd ../TIFF
new=1
for i in *.tif; do  
  mv -v $i  `printf '%08d' $new`.tif; (( new++ )); sleep .25
done

# fix all the exif tag information, extracting some of it for the old TIFFS
for file in *.tif; do

exiftool \
-SubFileType='Full-resolution Image' \
-Make='Canon' \
-Model='Canon EOS 5D Mark II' \
-XResolution=600 \
-YResolution=600 \
-ResolutionUnit=inches \
-Software='LIMB v2.3.1.6328' \
-OriginatingProgram='LIMB v2.3.1.6328' \
-ApplicationRecordVersion=4 \
-ColorSpace='sRGB' \
-DocumentName= \
-FileModifyDate="`exiftool -s ../../TIFF/00000001.tif | grep FileModifyDate | awk -F': ' '{ print $2 }'`" \
-CreateDate="`exiftool -s ../../TIFF/00000001.tif | grep FileModifyDate | awk -F': ' '{ print $2 }'`" \
-ModifyDate="`exiftool -s ../../TIFF/00000001.tif | grep FileModifyDate | awk -F': ' '{ print $2 }'`" \
${file}

sleep .25

done

# remove the original tiffs (exiftool generated new ones)
rm *_original

# back up the original 1 Bit TIFFS and move the new ones in place
cd ${basepath}
mv -v TIFF TIFF1BIT
sleep .25
mv -v PDF/TIFF .

echo "New TIFFs Generated -- don't forget to fix the METS MD5s"

# After running this script -- run the python script that regenerates the METS using the new TIFF checksums
# We'll chmod 664 the current METS file here so that the python script can do its thing
chmod 775 METS
chmod 664 METS/*.xml
