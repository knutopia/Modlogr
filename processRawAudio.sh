#!/bin/bash

id="processRawAudio.sh"
echo `date '+%F_%H:%M:%S'` $id >>/home/pi/logster.log

if [ ! -d "/home/pi/processingRecordings" ] ; then
  mkdir /home/pi/processingRecordings
fi

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
if test -n "$(find /home/pi/rawRecordings/ -maxdepth 1 -name '*.flac')" ; then

#LEDhandler.sh processingStart
/bin/bash -c '2>&1 1>>/home/pi/logster.log /usr/local/bin/LEDhandler.sh processingStart'
for rawFile in /home/pi/rawRecordings/*.flac ; do

  origFileName="$(basename $rawFile .flac)"
  targetDirectoryName="/home/pi/processedRecordings/Recording_from_"${origFileName#*_}

  if ! [[ `lsof -f -w -- "$rawFile"` ]] ; then  #not open?

    if [ `find "$rawFile" -mmin +1` ] ; then    #not touched within the last minute?

      echo $id "File not open, not too fresh - good to go:" \
      "$origFileName" >>/home/pi/logster.log

      if [ ! -d "/home/pi/processingRecordings" ] ; then
        mkdir /home/pi/processingRecordings
      fi

      echo $id "-Splitting" "$origFileName" >>/home/pi/logster.log

      nice -n 10 ffmpeg -y -hide_banner -loglevel quiet -stats \
      -i "$rawFile" \
      -f segment -segment_time 3600 -c:a pcm_s24be \
      /home/pi/processingRecordings/"$origFileName"-%03d_interim.aiff
      ffsuccess=$?
      if [ "${ffsuccess}" -ne "0" ] ; then
        echo $id "-FAILED to split" "$origFileName" >>/home/pi/logster.log
        success=false
      fi

      if [ ! -d "/home/pi/processedRecordings" ] ; then
        mkdir /home/pi/processedRecordings
      fi

      if [ ! -d $targetDirectoryName ] ; then
        mkdir $targetDirectoryName
      fi


      for interimFile in /home/pi/processingRecordings/*.aiff ; do

        interimFileName="$(basename $interimFile)"
        targetFileName="$(basename $interimFile _interim.aiff).flac"
        echo $id "--Recompressing flac from" "$interimFileName" \
        >>/home/pi/logster.log

        nice -n 10 ffmpeg -y -hide_banner -loglevel quiet -stats \
        -i "$interimFile" \
        $targetDirectoryName"/"$targetFileName
        ffsuccess=$?
        # delete interim file upon successful recompression
	if [ "${ffsuccess}" -eq "0" ] ; then
	  echo $id "--Recompressed to" "$targetFileName" \
          >>/home/pi/logster.log
	  rm "$interimFile"
	else
          echo $id "--FAILED to recompress" "$interimFile" "to" "$targetFileName" \
          >>/home/pi/logster.log
          success=false
	fi
      done

      # delete raw file upon overall success
      if [[ $success == true ]] ; then
        echo $id "-Success found, deleting raw file." \
        >>/home/pi/logster.log
        rm "$rawFile"
        rmdir /home/pi/processingRecordings/
      else
        echo $id "-Success elusive, keeping raw file." \
        >>/home/pi/logster.log
      fi

    else
      echo $id "File too fresh to touch, skipping:" "$origFileName" \
      >>/home/pi/logster.log
    fi
  else
    echo $id "File open, skipping:" "$origFileName" \
    >>/home/pi/logster.log
  fi
done 
else
  echo $id "No flac files found" >>/home/pi/logster.log
fi

/bin/bash -c '2>&1 1>>/home/pi/logster.log /usr/local/bin/LEDhandler.sh updateAfterProcessing'

if [[ $success == true ]] ; then
  echo `date '+%F_%H:%M:%S'` $id "Exiting 0" >>/home/pi/logster.log
  exit 0
else
  echo `date '+%F_%H:%M:%S'` $id "Exiting 1" >>/home/pi/logster.log
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
