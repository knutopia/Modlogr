#!/bin/bash

id="install.sh"
log_file="/home/pi/Modlogr/logs/logster.log"
touch $log_file
echo `date '+%F_%H:%M:%S'` $id >>$log_file

sudo chown root monitrc
sudo cp monitrc /etc/monit/
