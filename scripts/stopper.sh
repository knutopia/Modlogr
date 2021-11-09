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

# script called from monit as defined in monitrc
# stops the raw audio recording if it is active

pidFile="/home/pi/Modlogr/ffmpeg.pid"
#process_flag_file="/home/pi/Modlogr/processFlag.txt"
id="stopper.sh"
echo `date '+%F_%H:%M:%S'` $id

if [[ -f $pidFile  ]]; then
  echo -n $id "Pid file found."
  #does the process exist?

  pgrep -F $pidFile> /dev/null
  found_alive=$?

  if [[ $found_alive -eq 1 ]]; then
    echo $id "Pid file is stale. Removing it."
    rm $pidFile
  else
    foo=0
    while pgrep -F $pidFile; do
      echo -n $id "Pid is live - killing it"
      pkill -SIGTERM -F $pidFile
      sleep 1
      ((foo++))
      if [[ $foo -eq 60 ]]; then
        break
      fi
    done

    #did it work?
    pgrep -F $pidFile> /dev/null
    pid_is_stale=$?

    if [[ $pid_file_is_stale -eq 1 ]]; then
      echo $id "Didn't work, trying harder."
      kill -SIGKILL `cat $pidFile`
    else
      echo $id "It's dead."
    fi
    rm $pidFile
    /home/pi/Modlogr/scripts/LEDhandler.sh recordingStop
  fi
else
  echo $id "No pid file, no kill."
fi
