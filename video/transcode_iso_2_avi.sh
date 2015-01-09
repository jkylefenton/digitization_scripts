#!/bin/bash

for vob in $( ls *.vob ); do

ffmpeg -i $vob

done | ffmpeg -i -acodec copy -vcodec copy file.avi

