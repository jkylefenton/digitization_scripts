#! /bin/bash

IFS=$'\t\n'

basepath=$1

for proddir in `find ${basepath} -type d -name "*PROD"`
  do
  archdir=`echo ${proddir/PROD/ARCH}`
  parentdir=`echo ${proddir%?????}`
  currpath=$PWD
echo ${currpath}

  if [ ! -d ${archdir} ]
    then echo "let's create an ARCH dir then!"
    mkdir ${archdir}
    cd ${parentdir}
    echo "Removing spaces from ARCH filenames (if present)"
    for i in *.tif; do
      mv -v "${i}" "${i//[[:space:]]}"
    done
    echo "Moving *_ARCH.tif files to ARCH subdirectory"
    mv -v *ARCH.tif ARCH/
    cd ${currpath}
    cd ${proddir}
    for file in `ls *ARCH.tif` 
      do
        nospaces=`echo ${file//[[:space:]]}`
        prodname=`echo ${nospaces/ARCH/PROD}`
        mv -v "${file}" "${prodname}"
      done
    cd ${currpath}
  else
    echo "${archdir} already exists"
    cd ${archdir}
    for file in `ls *.tif`
      do
      archname=`echo -e ${file//[[:space:]]}`
      mv -v "${file}" "${archname}"
    done
    cd ${currpath}
    cd ${proddir}
    for file in `ls *.tif`
      do
      prodname=`echo -e ${file//[[:space:]]}`
      mv -v "${file}" "${prodname}"
    done
    for file in `ls *ARCH.tif`
      do
        prodname=`echo ${file/ARCH/PROD}`
        mv -v "${file}" "${prodname}"
      done
    cd ${currpath}
  fi

done
