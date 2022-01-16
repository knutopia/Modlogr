#!/bin/bash

# Modlogr: automatic headless USB audio recorder on Raspberry Pi with external USB audio interface
#    Copyright (C) 2021  Knut Graf
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

# This script records the USB audio card to a file per channel
# when the USB audio card is found to be available.
# The incoming channels are also played back on the card for visual feedback.


  # Expert Sleepers ES-9 
  # appears as 16 channel device
  # it records 24bit in at 32 / 96 (& 48?) kHz

  # We record the first 8 tracks for now,
  # with a .flac file per track for post processing

# Use this line to debug ffmpeg output to a log detailed file
# instead of using the -hide_banner -loglevel error -stats options:
# ffmpeg -y -report \

  local_log_file="/home/pi/Modlogr/logs/ffmpeg.log"
  local_id="recordAudio.sh"

  echo -n `date '+%F_%H:%M:%S'` $local_id
  
  ffmpeg -y -hide_banner -loglevel error \
  -guess_layout_max 2 -f alsa \
  -codec:a pcm_s24le -re \
  -ac 16 -ar 48000 -i hw:CARD=ES9 \
  -f alsa default \
  -map_channel 0.0.0 "$head"track1_"$tail" \
  -map_channel 0.0.1 "$head"track2_"$tail" \
  -map_channel 0.0.2 "$head"track3_"$tail" \
  -map_channel 0.0.3 "$head"track4_"$tail" \
  -map_channel 0.0.4 "$head"track5_"$tail" \
  -map_channel 0.0.5 "$head"track6_"$tail" \
  -map_channel 0.0.6 "$head"track7_"$tail" \
  -map_channel 0.0.7 "$head"track8_"$tail" \
  2> $local_log_file \
  & new_pid=$!
 
