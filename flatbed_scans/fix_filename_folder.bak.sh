#! /bin/bash

basepath=$1

for proddir in `find ${basepath} -type d -name "*PROD"`
  do
  archdir=`echo ${proddir} | tr "PROD" "ARCH"`
  parentdir=`echo ${proddir%?????}`
  currpath=$PWD

#echo -en "${proddir}\t"
#echo -en "${archdir}\t"
#echo -en "${parentdir}\t"

  if [ ! -d ${archdir} ]
    then echo "let's create an arch dir then!"
    mkdir ${archdir}
    cd ${parentdir}
echo -en "${PWD}\t"
    mv -v *_ARCH.tif ARCH/
    cd ${currpath}
echo -en "${PWD}\t"
    cd ${proddir}
echo -e "${PWD}\t"
    for file in `ls *ARCH.tif` 
      do
        prodname=`echo ${file} | tr "ARCH" "PROD"`
        mv -v ${file} ${prodname}
#        echo -e "${file}\t${prodname}"
      done
    cd ${currpath}
  else
    echo "${archdir} already exists"
    cd ${archdir}
    for file in `ls *.tif`
      do
      archname=`echo -e ${file} | tr -d " "`
      mv -v "${file}" "${archname}"
    done
    cd ${currpath}
    cd ${proddir}
    for file in `ls *.tif`
      do
      prodname=`echo -e ${file} | tr -d " "`
      mv -v "${file}" "${prodname}"
    done
    for file in `ls *ARCH.tif`
      do
        prodname=`echo ${file} | tr "ARCH" "PROD"`
        mv -v ${file} ${prodname}
      done
    cd ${currpath}
  fi

done
