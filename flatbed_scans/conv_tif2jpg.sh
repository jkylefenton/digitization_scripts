for tif in $( ls  ); do convert $tif ../JPG/`basename $tif .tif`.jpg; done
