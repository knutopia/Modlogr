#!/bin/bash

# For a raw recording, this script creates one or more interim 
# .aiff files of up to an hour in duration.

# Use the following line to debug ffmpeg output to a log detailed file
# instead of using the -hide_banner option
# ffmpeg -y -report \

  local_log_file_one="/home/pi/Modlogr/logs/ffmpeg.log"
  local_id_one="processStepOne.sh"

  echo -n `date '+%F_%H:%M:%S'` $local_id_one
  
  nice -n 10 ffmpeg -y -hide_banner -loglevel quiet -stats \
  -i "$rawFile" \
  -f segment -segment_time 3600 -c:a pcm_s24be \
  /home/pi/Modlogr/processingRecordings/"$origFileName"-%03d_interim.aiff
  ffsuccess=$?
 
