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
