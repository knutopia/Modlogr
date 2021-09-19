#!/bin/bash
cmd=$1

#Script to show activity status on the built-in LED

. /home/pi/Modlogr/scripts/sourceCheck.sh
. /home/pi/Modlogr/scripts/isRecordingActive.sh

recordingPidFile="/home/pi/Modlogr/ffmpeg.pid"
log_file="/home/pi/Modlogr/logs/logster.log"
id="LEDhandler.sh"
echo `date '+%F_%H:%M:%S'` $id $cmd >>$log_file

case $cmd in
    recordingStart)  # sent from starter.sh after the ffmpeg recording
                     # process has been launched
                     # shows slow blink with short gap
      modprobe ledtrig_timer  #recording LED
      echo "timer" >/sys/class/leds/led0/trigger
      echo 2000 >/sys/class/leds/led0/delay_on
      echo 500 >/sys/class/leds/led0/delay_off 
      echo $id "recordingStart LED set" >>$log_file
    ;;
    recordingStop)   # sent from stopper.sh after the ffmpeg recording
                     # process has been stopped
                     # resets the LED (to show drive access) momentarily
      echo mmc0 >/sys/class/leds/led0/trigger
      echo $id "recordingStop LED reset" >>$log_file
    ;;
    processingStart) # sent from processRawAudio.sh when files to
                     # process have been found
#     echo $id "processingStart" >>$log_file
      if isRecordingActive ; then
                     # if recording is still active, it takes precedence
        echo $id "recording active, no LED update" >>$log_file
      else
                     # if not recording, show quick "busy" blink

        modprobe ledtrig_timer  #processing LED
        echo "timer" >/sys/class/leds/led0/trigger
        echo 500 >/sys/class/leds/led0/delay_on
        echo 500 >/sys/class/leds/led0/delay_off 
        echo $id "not recording, processing LED set" >>$log_file
      fi
    ;;
    updateAfterProcessing)  # sent from bottom of processRawAudio.sh 
                            # when done processing or when nothing found
#     echo $id "updateAfterProcessing" >>$log_file
      if isRecordingActive; then
                            # if recording is active, 
                            # activate recording pattern

        modprobe ledtrig_timer  #recording LED
        echo "timer" >/sys/class/leds/led0/trigger
        echo 2000 >/sys/class/leds/led0/delay_on
        echo 500 >/sys/class/leds/led0/delay_off 

        echo $id "recording found active LED set" >>$log_file
      else
        if sourceCheck; then
                            # not recording, not processing,
                            # input device available: default LED (disk)
          echo mmc0 >/sys/class/leds/led0/trigger
          echo $id "not recording, not processing, input available - LED reset" >>$log_file
        else
                            # no input device found
                            # show a fast "alarm" blink
          modprobe ledtrig_timer  #source unavailable LED
          echo "timer" >/sys/class/leds/led0/trigger
          echo 100 >/sys/class/leds/led0/delay_on
          echo 150 >/sys/class/leds/led0/delay_off 
          echo $id "source unavailable LED set" >>$log_file
        fi
      fi
    ;;
    *)
      echo "catchall with" $cmd >>$log_file
      :
    ;;
esac
