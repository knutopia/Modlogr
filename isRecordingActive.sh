#!/bin/bash

recordingPidFile="/home/pi/ffmpeg.pid"
me="IRA"

isRecordingActive(){
if [[ -f $recordingPidFile  ]]; then
  pgrep -F $recordingPidFile >/dev/null
  found_alive=$?

  if [[ $found_alive -eq 1 ]]; then
    echo $me "found dead"
    return 1
  else
    echo $me "found alive"
    return 0
  fi
else
  echo $me "no pidfile"
  return 1
fi
}
