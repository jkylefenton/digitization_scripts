#!/bin/bash
for i in $( ls *.wav ); do
   ~/nero/linux/neroAacEnc -cbr 320000 -if $i -of `basename $i .wav`.m4a
done
