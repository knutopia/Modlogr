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

pid_file="/home/pi/ffmpeg.pid" # watched by monit
log_file="/home/pi/ffmpeg.log"            # debug use
src_chk_file="/home/pi/sourceCheck.log"   # debug use
recordings_file="/home/pi/recordings.log" # debug use
#process_flag_file="/home/pi/processFlag.txt" # checked by monit to start
                                             # post processing of recordings
id="starter.sh"
echo $id `date '+%F_%H:%M:%S'`

printf -v sourceCheckTime '%(%Y-%m-%d_%H:%M)T'_sourceCheck

if sourceCheck ; then
  echo "$sourceCheckTime" passed >> $src_chk_file
  echo $id "$sourceCheckTime" passed

  printf -v head '/home/pi/rawRecordings/' ;
  printf -v tail '%(%Y-%m-%d_%H:%M)T'.flac -1 ;

  if [ ! -d "/home/pi/rawRecordings" ] 
  then
    mkdir /home/pi/rawRecordings
  fi
  cd /home/pi/

  # Expert Sleepers ES-8 
  # appears as 8 channel device with a 7.1 channel layout
  # it records 24bit in a 32bit package (pcm_s32le) at 48kHz

  # The first output mixes 4 incoming channels to the 8 output
  # to play back on the ES8, too laggy to use musically
  # but good as an activity indicator 

  # The second output records a flac file
  # per track for post processing

  ffmpeg -y -hide_banner \
  -guess_layout_max 2 -f alsa \
  -codec:a pcm_s32le -re \
  -ac 8 -ar 48000 -i hw:CARD=ES8 \
  -af "pan=7.1|\
  FL<FL+.75*FC+.25*LFE|FR<FR+.75*LFE+.25*FC|\
  BL<FL+FR+FC+LFE|BR<FL+FR+FC+LFE|\
  FC=FL|LFE=FR|SL=FC|SR=LFE" \
  -f alsa default \
  -map_channel 0.0.0 "$head"track1_"$tail" \
  -map_channel 0.0.1 "$head"track2_"$tail" \
  -map_channel 0.0.2 "$head"track3_"$tail" \
  -map_channel 0.0.3 "$head"track4_"$tail" \
  & ffmpeg_pid=$!

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
