#! /bin/bash

IFS=$'\t\n'
# echo -e "DigWF_ID\tOCLC\tImagePath\tImageCount\tImageDPI\tImageBitDepth\tMARC\tARKPID\tVolume\tCollection_ID\tOwningLibraryID\tIA_ID"

while read line
do array=($line)

# S3 API Key
accesskey=""
secret=""

declare -a collections
collections[17]="africanamericanliterature"  # African American Imprints
collections[10]="" # Atlanta City Directories
collections[21]="baedeckers" # Baedecker Travel Guides
collections[8]="" # Brittle Books 
collections[13]="civilwardocuments" # Civil War Imprints
collections[18]="" # Early Northern European 
collections[16]="" # Emory Publications" 
collections[15]="" # Emory Yearbooks" 
collections[7]="" # General
collections[12]="" # Georgia State House Journals 
collections[14]="" # Georgia State Senate Journals
collections[4]="" # MARBL 
collections[1]="americanmethodism" # Methodism 
collections[11]="americanmethodism" # Methodist Conference Minutes
collections[9]="regimentalhistories" # Regimental Histories 
collections[5]="" # Theology Reference
collections[19]="tripledeckers"
collections[2]="yellowbacks"
collections[22]="medicalheritagelibrary" # Medical Heritage

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

digwf_id=${array[0]}
oclc=${array[1]} 
if [[ ${array[2]} == *E* ]]; then
  barcode=''
elif [[ ${array[2]}	== *NULL* ]]; then
  barcode=''
else
  barcode=$(printf "%012d\n" ${array[2]})
fi
imagepath=`echo "${array[4]}${array[14]}"`
imagecount=`find ${imagepath} -type f -iname "*.tif" -o -iname "*.jpg" -maxdepth 1 2>/dev/null | wc -l`
imagesample=`find ${imagepath} -type f -iname "*.tif" -o -iname "*.jpg" -maxdepth 1 2>/dev/null | head -8 | tail -1`
imagedpi=`exiftool $imagesample | grep "X Resolution" | awk '{ print $4 }' | head -1`
imagebitdepth=`exiftool $imagesample | grep "Bits Per Sample" | awk '{ print $5 }'`
arkpid=${array[20]}
volume=${array[22]}
collection_id=${array[23]} 
collection=${collections[$collection_id]}
owninglibrary_id=${array[10]}  
ia_id=${array[31]} 
owninglibrary_id=`cat ${marcxmlpath} | xmllint --format - | grep -e 'code=\"5\"' | grep -E 'GEU|GEU-T|GEU-M|GEU-S|GEU-L|G0xC|GOxC' | head -1 -`
if [[ $owninglibrary_id == *GEU-M* ]]; then
  owninglibrary=${libraries[4]}
elif [[ $owninglibrary_id == *GEU-T* ]]; then
  owninglibrary=${libraries[6]}
elif [[ $owninglibrary_id == *GEU-S* ]]; then
  owninglibrary=${libraries[8]}
elif [[	$owninglibrary_id == *GEU-L* ]]; then
  owninglibrary=${libraries[7]}
elif [[ $owninglibrary_id == *G0xC* ]]; then
  owninglibrary=${libraries[9]}
elif [[ $owninglibrary_id == *GEU* ]]; then
  owninglibrary=${libraries[1]}
else 
  owninglibrary=${libraries[8]}
fi

if [ ! ${volume} == "NULL" ]; then
  ia_volume=$volume
else
  ia_volume='' 
fi

# Destroy and replace the _meta.xml file

echo curl  --location \
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
--header 'x-archive-meta-pid:'"$arkpid"'' \
--header 'x-archive-meta-barcode:'"$barcode"'' \
--header 'x-archive-meta-volume:'"$ia_volume"'' \
--header 'authorization: LOW '"$accesskey"':'"$secret"'' \
--request PUT --header 'content-length:0' \
http://s3.us.archive.org/${ia_id}

curl  --location \
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
--header 'x-archive-meta-pid:'"$arkpid"'' \
--header 'x-archive-meta-barcode:'"$barcode"'' \
--header 'x-archive-meta-volume:'"$ia_volume"'' \
--header 'authorization: LOW '"$accesskey"':'"$secret"'' \
--request PUT --header 'content-length:0' \
http://s3.us.archive.org/${ia_id}

# Replace the MARCXML file with a fixed version

 marcxmlpath=${array[4]}/${array[19]} 
 marcxml=`curl -s http://chivs01aleph02.hosted.exlibrisgroup.com:8991/uhtbin/get_bibrecord?oclc=${oclc} | xmllint -format -`
# marcxml=`cat ${marcxmlpath}`
 marcxmlfixed=${marcxml/\[electronic resource\]/}

 echo "$marcxmlfixed" > /tmp/marcxmlfixed.xml

 curl -v --location \
 --header 'authorization: LOW '"$accesskey"':'"$secret"'' \
 --upload-file /tmp/marcxmlfixed.xml \
 http://s3.us.archive.org/${ia_id}/${ia_id}_marc.xml

 rm /tmp/marcxmlfixed.xml

# sleep 120

done
