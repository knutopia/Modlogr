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
