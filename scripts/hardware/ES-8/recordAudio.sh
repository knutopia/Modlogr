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


  # Expert Sleepers ES-8 
  # appears as 8 channel device with a 7.1 channel layout
  # it records 24bit in a 32bit package (pcm_s32le) at 48kHz

  # The first output mixes 4 incoming channels to the 8 output
  # to play back on the ES8, too laggy to use musically
  # but good as an activity indicator 

  # The second output records a flac file
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
  2> $local_log_file \
  & new_pid=$!
