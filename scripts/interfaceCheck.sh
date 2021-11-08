#!/bin/bash

# Detect the connected audio interface

log_file="/home/pi/Modlogr/logs/logster.log"
local_id="interfaceCheck.sh"

interfaceCheck() {

  echo `date '+%F_%H:%M:%S'` $local_id $cmd >>$log_file

  interface=$(find /proc/asound -maxdepth 1 -type l)
  found=""

# alsa_interface=$(arecord -l)
# echo $alsa_interface

  cards=$(cat /proc/asound/cards)
  echo $cards

  case "$interface" in 
    *ES8*)
      found="ES8"
      ;;
    *USB*)
      found="Scarlett2i4"
      ;;
    *THR10*)
      found="THR10"
      ;;
  esac

  if [[ -z "$found" ]]; then
    echo $local_id "Interface not found:" $interface
    return 1
  else
    echo $local_id $found "found"
    return 0
  fi
}
