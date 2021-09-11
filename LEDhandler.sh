#!/bin/bash
cmd=$1

#Script to show activity status on the built-in LED

. /usr/local/bin/sourceCheck.sh
. /usr/local/bin/isRecordingActive.sh

recordingPidFile="/home/pi/ffmpeg.pid"
id="LEDhandler.sh"
echo `date '+%F_%H:%M:%S'` $id $cmd

case $cmd in
    recordingStart)  # sent from starter.sh after the ffmpeg recording
                     # process has been launched
                     # shows slow blink with short gap
      modprobe ledtrig_timer  #recording LED
      echo "timer" >/sys/class/leds/led0/trigger
      echo 2000 >/sys/class/leds/led0/delay_on
      echo 500 >/sys/class/leds/led0/delay_off 
#     echo $id "recordingStart"
    ;;
    recordingStop)   # sent from stopper.sh after the ffmpeg recording
                     # process has been stopped
                     # resets the LED (to show drive access) momentarily
      echo mmc0 >/sys/class/leds/led0/trigger
#     echo $id "recordingStop"
    ;;
    processingStart) # sent from processRawAudio.sh when files to
                     # process have been found
#     echo $id "processingStart"
      if isRecordingActive ; then
                     # if recording is still active, it takes precedence
        echo $id "recording active, no LED update"
      else
                     # if not recording, show quick "busy" blink
        echo $id " not recording, showing processing LED"

        modprobe ledtrig_timer  #processing LED
        echo "timer" >/sys/class/leds/led0/trigger
        echo 500 >/sys/class/leds/led0/delay_on
        echo 500 >/sys/class/leds/led0/delay_off 
      fi
    ;;
    updateAfterProcessing)  # sent from bottom of processRawAudio.sh 
                            # when done processing or when nothing found
#     echo $id "updateAfterProcessing"
      if isRecordingActive ; then
                            # if recording is active, 
                            # activate recording pattern
        echo $id " recording found active"

        modprobe ledtrig_timer  #recording LED
        echo "timer" >/sys/class/leds/led0/trigger
        echo 2000 >/sys/class/leds/led0/delay_on
        echo 500 >/sys/class/leds/led0/delay_off 
      else
        if sourceCheck; then
                            # not recording, not processing,
                            # input device available: default LED (disk)
          echo $id " not recording, not processing, input available"
          echo mmc0 >/sys/class/leds/led0/trigger
        else
                            # no input device found
                            # show a fast "alarm" blink
          echo $id " source unavailable"
          modprobe ledtrig_timer  #source unavailable LED
          echo "timer" >/sys/class/leds/led0/trigger
          echo 150 >/sys/class/leds/led0/delay_on
          echo 150 >/sys/class/leds/led0/delay_off 
        fi
      fi
    ;;
    *)
      echo "catchall with" $cmd
      :
    ;;
esac
