#!/bin/bash

pid_file="/home/pi/recordingProcessing.pid"
#process_flag_file="/home/pi/processFlag.txt"
id="processingStarter.sh"
echo $id `date '+%F_%H:%M:%S'`

#if [ -f $process_flag_file ]; then

#  age=$(($(date +%s) - $(date +%s -r $process_flag_file)))

#  echo $id "Found processingFlag.txt"

#  if [[ $age < 60 ]] ; then    #not touched within the last minute?
#    echo $id "sleeping" $(( 60 - $age ))
#    sleep $(( 60 - $age ))
#  fi

#else
#  echo $id "processFlag.txt not found. That's odd..."
#fi

if [ -f $pid_file  ]; then
  echo $id "recordingProcessing Pid file found."
  #does the process exist?
  pgrep -F $pid_file
  pid_file_is_stale=$?

  if [ $pid_file_is_stale -eq 1 ]; then
    echo $id "Pid file found, stale. Removing it."
    rm $pid_file
  else
    echo $id "Pid file found, live. Exiting."
    exit 1
  fi
fi

echo $id "Starting processing."
processRecordings.sh & 
processing_pid=$!

echo $processing_pid > $pid_file

#if [ -f $process_flag_file ]; then
#  echo $id "Removing processingFlag.txt"
#  rm $process_flag_file
#fi
