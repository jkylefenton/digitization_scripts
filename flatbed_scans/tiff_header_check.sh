# ! /bin/bash
# 
# TIFf_header_check.sh
#
# This script provides a count for all files that have:
#   1) required header fields for baseline TIFFs 
#   2) required or recommended elements from Z39.87 Data Dictionary

# usage sh TIFf_header_check.sh (directory path)

echo -n 'Total TIFF Count\t\t'

ls $1/*.TIF | wc -l 
echo -n 'ImageWidth\t\t\t'
exiftool -s *.TIF | grep ImageWidth | grep -v Exif | wc -l
echo -n 'ImageHeight\t\t\t'
exiftool -s *.TIF | grep ImageHeight | grep -v Exif | wc -l
echo -n 'BitsPerSample\t\t\t'
exiftool -s *.TIF | grep BitsPerSample | grep -v Exif | wc -l
echo -n 'Compression\t\t\t'
exiftool -s *.TIF | grep Compression | grep -v Exif | wc -l
echo -n 'PhotometricInterpretation\t'
exiftool -s *.TIF | grep Photometric | grep -v Exif | wc -l
echo -n 'Make\t\t\t\t'
exiftool -s *.TIF | grep Make | grep -v Exif | wc -l
echo -n 'Model\t\t\t\t'
exiftool -s *.TIF | grep Model | grep -v Device | wc -l
echo -n 'StripOffsets\t\t\t'
exiftool -s *.TIF | grep StripOffsets | wc -l
echo -n 'Orientation\t\t\t'
exiftool -s *.TIF | grep Orientation | wc -l
echo -n 'SamplesPerPixel\t\t\t'
exiftool -s *.TIF | grep SamplesPerPixel | wc -l
echo -n 'RowsPerStrip\t\t\t'
exiftool -s *.TIF | grep RowsPerStrip | wc -l
echo -n 'StripByteCounts\t\t\t'
exiftool -s *.TIF | grep StripByteCounts | wc -l
echo -n 'XResolution\t\t\t'
exiftool -s *.TIF | grep XResolution | wc -l
echo -n 'YResolution\t\t\t'
exiftool -s *.TIF | grep YResolution | wc -l
echo -n 'Software\t\t\t'
exiftool -s *.TIF | grep Software | grep -v Agent | wc -l
echo -n 'DateTimeCreated\t\t\t'
exiftool -s *.TIF | grep DateTimeCreated | wc -l
echo -n 'Artist\t\t\t\t'
exiftool -s *.TIF | grep Artist | wc -l
echo
echo
echo -n 'Random Example\t\t'
echo
exiftool -s `ls *.TIF | sort --random-sort | head -1` | egrep 'ImageWidth|ImageHeight|BitsPerSample|Compression|Photometric|Make|Model|StripOffsets|Orientation|SamplesPerPixel|RowsPerStrip|StripByteCounts|XResolution|YResolution|Software|DateTimeCreated|Artist' | grep -v 'HistorySoftwareAgent' | grep -v 'DeviceModel'
