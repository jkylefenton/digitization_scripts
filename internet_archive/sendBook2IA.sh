
# ! /bin/bash
#
#  sendBook2IA.sh

# Description: Emory University to Internet Archive Deposits using S3-like API
# Author: Kyle Fenton, Emory University
# Date: 10/22/2014

IFS=$'\t\n'

# echo -e "DigWF_ID\tOCLC\tbarcode\tImagePath\tImageCount\tImageDPI\tImageBitDepth\tMARC\tARKPID\tVolume\tCollection_ID\tOwningLibraryID\tIA_ID"

# read in tab delimited file of digitized book metadata records, populate array
while read -r -a array; do 

# Internet Archive S3-Like API Key
# Maintained at https://archive.org/account/s3.php  
accesskey=""
secret=""

# Create an array mapping Digitization Projects to Internet Archive meta02-collection
declare -a collections
collections[17]="africanamericanliterature"  	# African American Imprints
collections[10]="" 								# Atlanta City Directories
collections[21]="baedeckers" 					# Baedecker Travel Guides
collections[8]="" 								# Brittle Books 
collections[13]="civilwardocuments" 			# Civil War Imprints
collections[18]="" 								# Early Northern European 
collections[16]="" 								# Emory Publications
collections[15]="" 								# Emory Yearbooks
collections[7]="" 								# General
collections[12]="" 								# Georgia State House Journals 
collections[14]="" 								# Georgia State Senate Journals
collections[4]="" 								# MARBL 
collections[1]="americanmethodism" 				# Methodism 
collections[11]="americanmethodism" 			# Methodist Conference Minutes
collections[9]="regimentalhistories" 			# Regimental Histories 
collections[5]="" 								# Theology Reference
collections[19]="tripledeckers"					# Triple (Three) Deckers
collections[2]="yellowbacks"					# Yellowbacks
collections[22]="medicalheritagelibrary" 		# Medical Heritage Imprints

# Create an array to map campus libraries into Internet Archive meta-sponsor and meta-contributor
declare -a libraries
libraries[1]="Robert W. Woodruff Library"
libraries[2]="Goizueta Business Library"
libraries[3]="Marian K. Heilbrun Music and Media Library"
libraries[4]="Woodruff Health Sciences Center Library"
libraries[5]="James S. Guy Chemistry Library"
libraries[6]="Pitts Theology Library"
libraries[7]="Hugh F. Macmillan Library"
libraries[8]="Manuscript, Archives and Rare Book Library"
libraries[9]="Oxford College Library" 

# Assign array elements to more meaningful variables
digwf_id=${array[0]}							# Digitization Job Number
oclc=${array[1]} 								# OCLC number
oclc_trimmed=`echo ${oclc} | tr -d ocm`			# trimmed version of OCLC number (numbers only)
if [[ ${array[2]} == *E* ]]; then
  barcode=''
  echo "[Error] No barcode number supplied for ${digwf_id}."
  continue
elif [[ ${array[2]}     == *NULL* ]]; then
  barcode=''
  echo "[Error] No barcode number supplied for ${digwf_id}."
  continue
else
  barcode=$(printf "%012d\n" ${array[2]})		# Physical volume's barcode
fi
imagepath=`echo "${array[4]}${array[12]}"`		# Path to TIF (or JPG) images
imagecount=`find ${imagepath} -type f -iname "*.tif" -o -iname "*.jpg" -maxdepth 1 2>/dev/null | wc -l`   # Count of images
imagesample=`find ${imagepath} -type f -iname "*.tif" -o -iname "*.jpg" -maxdepth 1 2>/dev/null | head -8 | tail -1`	# Sample image to examine (arbitrarily choosing the 8th image)
imagedpi=`exiftool $imagesample | grep "X Resolution" | awk '{ print $4 }' | head -1`	# PPI resolution of the sampled image
imagebitdepth=`exiftool $imagesample | grep "Bits Per Sample" | awk '{ print $5 }'`		# Bitdepth of the sampled image (to determine if bitonal, grayscale, or color)
arkpid=${array[18]}								# identifier from Archival Resource Key for the digitized volume

volume=${array[20]}								# Enumeration / Chronology info for the volume (if applicable)
if [ ! ${volume} == "NULL" ]; then
  ia_volume=${volume}
else
  ia_volume='' 
fi

collection_id=${array[21]} 						# Project ID assigned during digitization
collection=${collections[$collection_id]}		# mapping project ID into variable used for IA meta-collection 
marcxmlpath=`echo "${array[4]}/${array[17]}" | tr \\\\ \\`								# path to the MARCXML file for the volume
echo ${marcxmlpath}
echo

# Get ID of campus library that owns the volume from the MARCXML record and assign the appropriate meta-sponsor and meta-contributor
owninglibrary_id=`cat ${marcxmlpath} | xmllint --format - | grep -e 'code=\"5\"' | grep -E 'GEU|GEU-T|GEU-M|GEU-S|GEU-L|G0xC|GOxC' | head -1 -` 
if [[ $owninglibrary_id == *GEU-M* ]]; then
  owninglibrary=${libraries[4]}
elif [[ $owninglibrary_id == *GEU-T* ]]; then
  owninglibrary=${libraries[6]}
elif [[ $owninglibrary_id == *GEU-S* ]]; then
  owninglibrary=${libraries[8]}
elif [[ $owninglibrary_id == *GEU-L* ]]; then
  owninglibrary=${libraries[7]}
elif [[ $owninglibrary_id == *G0xC* ]]; then
  owninglibrary=${libraries[9]}
elif [[ $owninglibrary_id == *GEU* ]]; then
  owninglibrary=${libraries[1]}
else 
  owninglibrary=${libraries[8]}
fi

# Concatenate the OCLC number and the last five digits of the barcode to mint a unique Internet Archive Identifier

if [ ! -n ${oclc} ] ; then

    echo "[Error] No OCLC number supplied for ${digwf_id}."
    continue
fi
if [ ! -n ${barcode} ] ; then

    echo "[Error] No barcode number supplied for ${digwf_id}."
    continue
fi

# Create IA bucket and meta.xml, and upload marcxml

if [ ! -e ${marcxmlpath} ]; then
  echo "[Error] No MARCXML file at the supplied path for ${digwf_id}" 
  continue
fi

marcxml=`curl -s http://chivs01aleph02.hosted.exlibrisgroup.com:8991/uhtbin/get_bibrecord?oclc=${oclc} | xmllint -format -`
# marcxml=`cat ${marcxmlpath}`
marcxmlfixed=${marcxml/\[electronic resource\]/}
echo "${marcxmlfixed}" > /tmp/marcxmlfixed.xml

echo "DigWF ${digwf_id} Bucket ID will be ${oclc_trimmed}.${barcode:7}.emory.edu"

curl -vs  --location \
--header 'x-amz-auto-make-bucket:1' \
--header 'x-archive-ignore-preexisting-bucket:1' \
--header 'x-archive-queue-derive:0' \
--header 'x-archive-meta-mediatype:texts' \
--header 'x-archive-meta-sponsor:Emory University, '"$owninglibrary"'' \
--header 'x-archive-meta-contributor:Emory University, '"$owninglibrary"'' \
--header 'x-archive-meta01-collection:emory' \
--header 'x-archive-meta02-collection:'"$collection"'' \
--header 'x-archive-meta-ppi:'"$imagedpi"'' \
--header 'x-archive-meta-imagecount:'"$imagecount"'' \
--header 'x-archive-meta-bitdepth:'"$imagebitdepth"'' \
--header 'x-archive-meta-pid:'"$arkpid"'' \
--header 'x-archive-meta-oclc:'"$oclc_trimmed"'' \
--header 'x-archive-meta-barcode:'"$barcode"'' \
--header 'x-archive-meta-volume:'"$ia_volume"'' \
--header 'authorization: LOW '"$accesskey"':'"$secret"'' \
--upload-file /tmp/marcxmlfixed.xml  http://s3.us.archive.org/${oclc_trimmed}.${barcode:7}.emory.edu/${oclc_trimmed}.${barcode:7}.emory.edu_marc.xml

sleep 4

# Create a zip file of the images to be uploaded

# echo 'zip -v '"${oclc_trimmed}"'.'"${barcode:7}"'_images.zip `find '"${imagepath}"' -type f -iname "*.tif" -o -iname "*.jpg" -maxdepth 1 2>/dev/null`'
# zip -v /mnt/lsdi/tmp/${oclc_trimmed}.${barcode:7}_images.zip `find ${imagepath} -type f -iname "*.tif" -o -iname "*.jpg" -maxdepth 1 2>/dev/null`

# zip -v ${oclc_trimmed}.${barcode:7}_images.zip `find ${imagepath} -type f -iname "*.tif" -o -iname "*.jpg" -maxdepth 1 2>/dev/null`
# echo 'find ${imagepath} -type f -iname "*.tif" -o -iname "*.jpg" -maxdepth 1 -exec zip -v ${oclc_trimmed}.${barcode:7}_images.zip {} \;'
# find ${imagepath} -type f -iname "*.tif" -o -iname "*.jpg" -maxdepth 1 -exec zip -v ${oclc_trimmed}.${barcode:7}_images.zip {} \;

# sleep 10

# Upload the zip file

# size=`wc -c ${oclc_trimmed}.${barcode:7}_images.zip | awk '{ print $1 }'`
# echo "DigWF ${digwf_id} size of zip file in bytes is ${size}"
# echo
# curl -v --location \
# --header 'x-archive-size-hint:'"$size"'' \
# --header 'authorization: LOW '"$accesskey"':'"$secret"'' \
# --upload-file /mnt/lsdi/tmp/test.zip \
# http://s3.us.archive.org/${oclc_trimmed}.${barcode:7}.emory.edu/${oclc_trimmed}.${barcode:7}.emory.edu_images.zip
# --upload-file ${oclc_trimmed}.${barcode:7}_images.zip \

# sleep 4 
# rm /mnt/lsdi/tmp/${oclc_trimmed}.${barcode:7}_images.zip
# rm test.zip

echo
echo -e "${arkpid}\t${oclc_trimmed}.${barcode:7}.emory.edu\t${oclc}\t${barcode}\tFINISHED"

done
