#!/bin/bash

for file in 00000001.tif; do

# modified=`exiftool -s ../../TIFF/00000001.tif | grep FileModifyDate | awk -F': ' '{ print $2 }'`

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
${file}

done
