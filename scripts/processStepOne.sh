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
 
