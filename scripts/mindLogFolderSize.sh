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

. /home/pi/Modlogr/scripts/isRecordingActive.sh

folder_path="/home/pi/Modlogr/logs"
log_file="/home/pi/Modlogr/logs/logster.log"
id="mindLogFolderSize.sh"
#echo `date '+%F_%H:%M:%S'` $id >>$log_file

size=$(/usr/bin/du -s $folder_path  | /usr/bin/awk '{print $1}')
echo `date '+%F_%H:%M:%S'` $id "${size}kB" >>$log_file

if [[ $size -gt $(( 1024 )) ]]; then

  if ! isRecordingActive ; then
    sudo truncate -c --size='<'100K /home/pi/Modlogr/logs/ffmpeg.log
    echo $id "trimming ffmpeg.log" >>$log_file
  fi
    echo $id "trimming other logs" >>$log_file  fi
  sudo truncate -c --size='<'100K /home/pi/Modlogr/logs/sourceCheck.log
  sudo truncate -c --size='<'100K /home/pi/Modlogr/logs/recordings.log
  sudo truncate -c --size='<'100K /home/pi/Modlogr/logs/monit.log
  sudo truncate -c --size='<'100K /home/pi/Modlogr/logs/logster.log
fi

