#!/bin/bash

 for i in $(cat eulrecords_oclc.txt); do

  `curl -# -C - -o "${2}" http://openlibrary.org/api/volumes/brief/json/oclc:$i`
  sleep 1

 done
