#!/bin/bash

# NOT CALLED FROM ANYWHERE YET- TODO
# this script finds the oldest folder of recordings 
# in /home/pi/Modlogr/processedRecordings and removes it.
# this is meant to happen automatically when monit 
# finds the disk filling up

id="purgeOldRecording.sh"
echo `date '+%F_%H:%M:%S'` $id

if [ ! -d "/home/pi/Modlogr/processedRecordings" ] ; then
  echo $id "no /home/pi/Modlogr/processedRecordings found!"
  exit 1
fi

oldestDir=$(ls /home/pi/Modlogr/processedRecordings | sort | head -n 1)
echo $id $oldestDir "will be removed"
rm -r /home/pi/Modlogr/processedRecordings/$oldestDir
if [ $? -eq 0 ]
then
  echo $id "It is done"
  exit 0
else
  echo $id "Purge failed" >&2
  exit 1
fi
