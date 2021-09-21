#!/bin/bash


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

