# ! /bin/bash
# 
# resolution.sh
#
# outputs filename and ppi, tab delimited, for each archival master in this directory
#

#  echo "Filename|ImageWidth|ImageHeight|BitsPerSample|Compression|PhotometricInterpretation|Make|Model|StripOffsets|Orientation|SamplesPerPixel|RowsPerStrip|StripByteCounts|XResolution|YResolution|PlanarConfiguration|ResolutionUnit|Software|DateCreated|TimeCreated|DateTimeCreated|Artist"
	
for file in $1/*_ARCH.tif; do 
  echo "$(basename ${file})|\c"; 
#  echo "`exiftool -D ${file} | egrep '^  256' | awk -F" : " '{ print $2 }'`|\c"; 
#  echo "`exiftool -D ${file} | egrep '^  257' | awk -F" : " '{ print $2 }'`|\c"; 
#  echo "`exiftool -D ${file} | egrep '^  258 '| awk -F" : " '{ print $2 }'`|\c"; 
#  echo "`exiftool -D ${file} | egrep '^  259' | awk -F" : " '{ print $2 }'`|\c"; 
#  echo "`exiftool -D ${file} | egrep '^  262' | awk -F" : " '{ print $2 }'`|\c"; 
#  echo "`exiftool -D ${file} | egrep '^  271' | awk -F" : " '{ print $2 }'`|\c"; 
#  echo "`exiftool -D ${file} | egrep '^  272' | awk -F" : " '{ print $2 }'`|\c"; 
#  echo "`exiftool -D ${file} | egrep '^  273' | awk -F" : " '{ print $2 }'`|\c"; 
#  echo "`exiftool -D ${file} | egrep '^  274' | awk -F" : " '{ print $2 }'`|\c"; 
#  echo "`exiftool -D ${file} | egrep '^  277' | awk -F" : " '{ print $2 }'`|\c"; 
#  echo "`exiftool -D ${file} | egrep '^  278' | awk -F" : " '{ print $2 }'`|\c"; 
#  echo "`exiftool -D ${file} | egrep '^  279' | awk -F" : " '{ print $2 }'`|\c"; 
  echo "`exiftool -D ${file} | egrep '^  282' | awk -F" : " '{ print $2 }'`"; 
#  echo "`exiftool -D ${file} | egrep '^  283' | awk -F" : " '{ print $2 }'`|\c"; 
#  echo "`exiftool -D ${file} | egrep '^  284' | awk -F" : " '{ print $2 }'`|\c"; 
#  echo "`exiftool -D ${file} | egrep '^  296' | awk -F" : " '{ print $2 }'`|\c"; 
#  echo "`exiftool -D ${file} | egrep '^  305' | awk -F" : " '{ print $2 }'`|\c"; 
#  echo "`exiftool -D ${file} | egrep '^  306' | awk -F" : " '{ print $2 }'`|\c"; 
#  echo "`exiftool -D ${file} | egrep '^  315' | awk -F" : " '{ print $2 }'`"; 
done
