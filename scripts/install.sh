#!/bin/bash

id="install.sh"
log_file="/home/pi/Modlogr/logs/logster.log"
echo `date '+%F_%H:%M:%S'` $id >>$log_file

sudo cp monitrc /etc/monit/
