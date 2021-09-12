#!/bin/bash

# This script records the USB audio card to a file per channel
# when the USB audio card is found to be available.
# The incoming channels are also played back on the card for visual feedback.
#
# Using other scripts, processingStarter.sh and processRecordings.sh,
# the recorded files are processed asynchronously after recording so they
# become suitable for direct import in Ableton Live:
# Recordings are split into 1-hr chunks as AIFF and then resaved as FLAC.
# The re-saving forces correct metatada as is expected by Ableton Live.
#
# These activities are coordinated by monit, using /etc/monit/monitrc

. /usr/local/bin/sourceCheck.sh
. /usr/local/bin/recordAudio.sh

pid_file="/home/pi/Modlogr/ffmpeg.pid" # watched by monit
log_file="/home/pi/Modlogr/Logs/ffmpeg.log"            # debug use
src_chk_file="/home/pi/Modlogr/Logs/sourceCheck.log"   # debug use
recordings_file="/home/pi/Modlogr/Logs/recordings.log" # debug use
#process_flag_file="/home/pi/Modlogr/processFlag.txt"  # checked by monit to start
                                                       # post processing of recordings
id="starter.sh"
echo `date '+%F_%H:%M:%S'` $id

printf -v sourceCheckTime '%(%Y-%m-%d_%H:%M)T'_sourceCheck

if sourceCheck ; then
  echo "$sourceCheckTime" passed >> $src_chk_file
  echo $id "$sourceCheckTime" passed

  printf -v head '/home/pi/Modlogr/rawRecordings/' ;
  printf -v tail '%(%Y-%m-%d_%H:%M)T'.flac -1 ;

  if [ ! -d "/home/pi/Modlogr/rawRecordings" ] 
  then
    mkdir /home/pi/Modlogr/rawRecordings
  fi
  if [ ! -d "/home/pi/Modlogr/Logs" ] 
  then
    mkdir /home/pi/Modlogr/Logs
  fi
  cd /home/pi/Modlogr/Logs

  ffmpeg_pid=$(recordAudio)

  echo $tail >> $recordings_file
  echo $ffmpeg_pid
  echo $ffmpeg_pid > $pid_file
  echo $ffmpeg_pid >> $src_chk_file
  >>/dev/null

  LEDhandler.sh recordingStart
  exit 0
else 
  echo "$sourceCheckTime" failed >> $src_chk_file
  echo $id "$sourceCheckTime" failed
  exit 1
fi
