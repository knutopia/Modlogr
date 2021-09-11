#!/bin/bash

if [ ! -d "/home/pi/rawRecordings" ] 
then
  mkdir /home/pi/rawRecordings
fi

test_file="/home/pi/rawRecordings/test.txt"
echo hi there >> $test_file 

