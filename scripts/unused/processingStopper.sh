#!/bin/bash

pidFile="/home/pi/recordingProcessing.pid"

if [ -f $pidFile  ]; then
  echo "recordingProcessing Pid file found."
  #does the process exist?
  pgrep -F $pidFile
  pid_file_is_stale=$?

  if [ $pid_file_is_stale -eq 1 ]; then
    echo "Pid file is stale. Removing it."
    rm $pidFile
  else
    echo "Pid is live - killing it."
    kill -SIGTERM `cat $pidFile`
    sleep 5
    
    #did it work?
    pgrep -F $pidFile
    pid_is_stale=$?

    if [ $pid_file_is_stale -eq 1 ]; then
      echo "Didn't work, trying harder."
      kill -SIGKILL `cat $pidFile`
    else
      echo "It's dead."
    fi
    rm $pidFile
  fi
else
  echo "recordingProcessing: No pid file, no kill."
fi

