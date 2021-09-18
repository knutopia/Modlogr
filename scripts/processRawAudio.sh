#!/bin/bash

id="processRawAudio.sh"
log_file="/home/pi/Modlogr/logs/logster.log"
echo `date '+%F_%H:%M:%S'` $id >>$log_file

#iterate over available raw recording files
#get raw recording file
# if its open for write by ffmpeg then skip it (next iteration)
# store its name
# split raw file into interim 1-hour aiffs
# re-encode each aiff to flac (to force correct metadata for Ableton Live)
# delete each interim file after re-encoding
# delete raw file and interim folder upon successful completion

success=true  #track execution to later delete raw file
              #and for exit code
if test -n "$(find /home/pi/Modlogr/rawRecordings/ -maxdepth 1 -name '*.flac')" ; then

#/home/pi/Modlogr/scripts/LEDhandler.sh processingStart
/bin/bash -c '2>&1 1>>$log_file /home/pi/Modlogr/scripts//home/pi/Modlogr/scripts/LEDhandler.sh processingStart'
for rawFile in /home/pi/Modlogr/rawRecordings/*.flac ; do

  origFileName="$(basename $rawFile .flac)"
  targetDirectoryName="/home/pi/Modlogr/processedRecordings/Recording_from_"${origFileName#*_}

  if ! [[ `lsof -f -w -- "$rawFile"` ]] ; then  #not open?

    if [ `find "$rawFile" -mmin +1` ] ; then    #not touched within the last minute?

      echo $id "File not open, not too fresh - good to go:" \
      "$origFileName" >>$log_file

      if [ ! -d "/home/pi/Modlogr/processingRecordings" ] ; then
        mkdir /home/pi/Modlogr/processingRecordings
      fi

      echo $id "-Splitting" "$origFileName" >>$log_file

#     nice -n 10 ffmpeg -y -hide_banner -loglevel quiet -stats \
#     -i "$rawFile" \
#     -f segment -segment_time 3600 -c:a pcm_s24be \
#     /home/pi/Modlogr/processingRecordings/"$origFileName"-%03d_interim.aiff
      source /home/pi/Modlogr/scripts/processStepOne.sh
      ffsuccess=$?
      if [ "${ffsuccess}" -ne "0" ] ; then
        echo $id "-FAILED to split" "$origFileName" >>$log_file
        success=false
      fi

      if [ ! -d "/home/pi/Modlogr/processedRecordings" ] ; then
        mkdir /home/pi/Modlogr/processedRecordings
      fi

      if [ ! -d $targetDirectoryName ] ; then
        mkdir $targetDirectoryName
      fi


      for interimFile in /home/pi/Modlogr/processingRecordings/*.aiff ; do

        interimFileName="$(basename $interimFile)"
        targetFileName="$(basename $interimFile _interim.aiff).flac"
        echo $id "--Recompressing flac from" "$interimFileName" \
        >>$log_file

#       nice -n 10 ffmpeg -y -hide_banner -loglevel quiet -stats \
#       -i "$interimFile" \
#       $targetDirectoryName"/"$targetFileName
        source /home/pi/Modlogr/scripts/processStepTwo.sh
        ffsuccess=$?
        # delete interim file upon successful recompression
	if [ "${ffsuccess}" -eq "0" ] ; then
	  echo $id "--Recompressed to" "$targetFileName" \
          >>$log_file
	  rm "$interimFile"
	else
          echo $id "--FAILED to recompress" "$interimFile" "to" "$targetFileName" \
          >>$log_file
          success=false
	fi
      done

      # delete raw file upon overall success
      if [[ $success == true ]] ; then
        echo $id "-Success found, deleting raw file." \
        >>$log_file
        rm "$rawFile"
      else
        echo $id "-Success elusive, keeping raw file." \
        >>$log_file
      fi
    else
      echo $id "File too fresh to touch, skipping:" "$origFileName" \
      >>$log_file
    fi
  else
    echo $id "File open, skipping:" "$origFileName" \
    >>$log_file
  fi
done 
 if [ -d "/home/pi/Modlogr/processingRecordings" ] ; then
   echo $id "Deleting processing folder" \
   >>$log_file
   rmdir /home/pi/Modlogr/processingRecordings/
 fi
else
  echo $id "No flac files found" >>$log_file
fi

/bin/bash -c '2>&1 1>>$log_file /home/pi/Modlogr/scripts//home/pi/Modlogr/scripts/LEDhandler.sh updateAfterProcessing'

if [[ $success == true ]] ; then
  echo `date '+%F_%H:%M:%S'` $id "Exiting 0" >>$log_file
  exit 0
else
  echo `date '+%F_%H:%M:%S'` $id "Exiting 1" >>$log_file
  exit 1
fi

# split it into 1hr aiff chunks
#  wait for completion
#  check for success

# iterate over aiff chunks
#  resave each as flac
#  check for success
#   delete resaved aiff chunk

# delete raw recording
#next iteration
#done
