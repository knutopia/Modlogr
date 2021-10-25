#!/bin/bash

# This script records the USB audio card to a file per channel
# when the USB audio card is found to be available.
# The incoming channels are also played back on the card for visual feedback.


  # Scarlett 2i4 (1st generation)
  # appears as 2 channel device
  # it records 24bit in a 32bit package (pcm_s32le) at 44.1kHz or 96kHz

  # The output records a flac file
  # per track for post processing

# Use this line to debug ffmpeg output to a log detailed file
# instead of using the -hide_banner -loglevel error -stats options:
# ffmpeg -y -report \

  local_log_file="/home/pi/Modlogr/logs/ffmpeg.log"
  local_id="recordAudio.sh"

  echo -n `date '+%F_%H:%M:%S'` $local_id
  
  ffmpeg -y -hide_banner -loglevel error \
  -guess_layout_max 2 -f alsa \
  -codec:a pcm_s32le -re \
  -ac 2 -ar 48000 -i hw:CARD=USB \
  -map_channel 0.0.0 "$head"track1_"$tail" \
  -map_channel 0.0.1 "$head"track2_"$tail" \
  2> $local_log_file \
  & new_pid=$!
