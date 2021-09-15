#!/bin/bash

# script called from monit as defined in monitrc
# stops the raw audio recording if it is active

pidFile="/home/pi/Modlogr/ffmpeg.pid"
#process_flag_file="/home/pi/Modlogr/processFlag.txt"
id="stopper.sh"
echo `date '+%F_%H:%M:%S'` $id

if [[ -f $pidFile  ]]; then
  echo $id "Pid file found."
  #does the process exist?

  pgrep -F $pidFile
  found_alive=$?

  if [[ $found_alive -eq 1 ]]; then
    echo $id "Pid file is stale. Removing it."
    rm $pidFile
  else
    foo=0
    while pgrep -F $pidFile; do
      echo $id "Pid is live - killing it"
      pkill -SIGTERM -F $pidFile
      sleep 1
      ((foo++))
      if [[ $foo -eq 60 ]]; then
        break
      fi
    done

    #did it work?
    pgrep -F $pidFile >/dev/null
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
