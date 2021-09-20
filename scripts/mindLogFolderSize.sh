#!/bin/bash

folder_path="/home/pi/Modlogr/logs"
log_file="/home/pi/Modlogr/logs/logster.log"
id="mindLogFolderSize.sh"
#echo `date '+%F_%H:%M:%S'` $id >>$log_file

size=$(/usr/bin/du -s $folder_path  | /usr/bin/awk '{print $1}')
echo `date '+%F_%H:%M:%S'` $id "${size}kB" >>$log_file

if [[ $size -gt $(( 450 )) ]]; then
  sudo truncate -c --size='<'100K /home/pi/Modlogr/logs/*.log
  result = %?
  echo $id "truncated" result >>$log_file
fi

