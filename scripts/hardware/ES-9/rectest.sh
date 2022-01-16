#!/bin/bash
  
  ffmpeg -y -hide_banner -loglevel error \
  -guess_layout_max 2 -f alsa \
  -codec:a pcm_s24le -re \
  -ac 16 -ar 48000 -i hw:CARD=ES9 \
  -f alsa default \
  -map_channel 0.0.0 track1.flac \
  -map_channel 0.0.1 track2.flac \
  -map_channel 0.0.2 track3.flac \
  -map_channel 0.0.3 track4.flac \
  -map_channel 0.0.4 track5.flac \
  -map_channel 0.0.5 track6.flac \
  -map_channel 0.0.6 track7.flac \
  -map_channel 0.0.7 track8.flac
