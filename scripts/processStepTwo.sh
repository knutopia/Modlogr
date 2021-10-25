#!/bin/bash

# This script re-saves an interim .aiff file 
# as a .flac file with correct metadata.

# Use the following line to debug ffmpeg output to a log detailed file
# instead of using the -hide_banner option
# ffmpeg -y -report \

  local_log_file_two="/home/pi/Modlogr/logs/ffmpeg.log"
  local_id_two="processStepTwo.sh"

  echo -n `date '+%F_%H:%M:%S'` $local_id_two
   
  nice -n 10 ffmpeg -y -hide_banner -loglevel quiet -stats \
  -i "$interimFile" \
  $targetDirectoryName"/"$targetFileName
  ffsuccess=$?

