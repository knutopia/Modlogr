#!/bin/bash

folder_path="/home/pi/Modlogr/logs"
log_file="/home/pi/Modlogr/logs/logster.log"
id="mindLogFolderSize.sh"
echo -n `date '+%F_%H:%M:%S'` $id >>$log_file

size=$(/usr/bin/du -s $folder_path  | /usr/bin/awk '{print $1}')
echo "$folder_path  -  ${size}kB" >>$log_file

if [[ $size -gt $(( 1024 )) ]]; then
  echo -n "truncating" >>$log_file
  sudo truncate -c --size='<'100K /home/pi/Modlogr/logs/*.log
  echo %? >>$log_file
fi

