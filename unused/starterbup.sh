#!/bin/bash

pid_file="/home/pi/ffmpeg.pid"

if [ sourceCheck ]
then
  printf -v head '/home/pi/' ;
  printf -v tail '%(%Y-%m-%d_%H:%M)T'.flac -1 ;

  arecord --device=plughw:1,0 -f s32_le \
  -r 48000  -c 8 | \
  ffmpeg -loglevel error -y -i - \
  -codec:a pcm_s32le \
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


  echo $ffmpeg_pid
  echo $ffmpeg_pid > $pid_file
  #>>/dev/null
  exit 0
else 
  exit 1
fi
