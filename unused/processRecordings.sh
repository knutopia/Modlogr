#!/bin/bash

id="processRecordings.sh"
echo $id `date '+%F_%H:%M:%S'`

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

if test -n "$(find /home/pi/rawRecordings/ -maxdepth 1 -name '*.flac')" ; then
for rawFile in /home/pi/rawRecordings/*.flac ; do

  origFileName="$(basename $rawFile .flac)"
  targetDirectoryName="/home/pi/processedRecordings/Recording_from_"${origFileName#*_}

  if ! [[ `lsof -f -w -- "$rawFile"` ]] ; then  #not open?

    if [ `find "$rawFile" -mmin +1` ] ; then    #not touched within the last minute?

      echo $id "File not open, not too fresh - good to go:" "$origFileName"

      success=true  #track execution to later delete raw file

      if [ ! -d "/home/pi/processingRecordings" ] ; then
        mkdir /home/pi/processingRecordings
      fi

      echo $id "-Splitting" "$origFileName"

      nice -n 10 ffmpeg -y -hide_banner -loglevel quiet -stats \
      -i "$rawFile" \
      -f segment -segment_time 3600 -c:a pcm_s24be \
      /home/pi/processingRecordings/"$origFileName"-%03d_interim.aiff
      ffsuccess=$?
      if [ "${ffsuccess}" -ne "0" ] ; then
        echo $id "-FAILED to split" "$origFileName"
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
        echo $id "--Recompressing flac from" "$interimFileName"

        nice -n 10 ffmpeg -y -hide_banner -loglevel quiet -stats \
        -i "$interimFile" \
        $targetDirectoryName"/"$targetFileName
        ffsuccess=$?
        # delete interim file upon successful recompression
	if [ "${ffsuccess}" -eq "0" ] ; then
	  echo $id "--Recompressed to" "$targetFileName"
	  rm "$interimFile"
	else
          echo $id "--FAILED to recompress" "$interimFile" "to" "$targetFileName"
          success=false
	fi
      done

      # delete raw file upon overall success
      if [[ $success == true ]] ; then
        echo $id "-Success found, deleting raw file."
        rm "$rawFile"
        rmdir /home/pi/processingRecordings
      else
        echo $id "-Success elusive, keeping raw file."
      fi

    else
      echo $id "File too fresh to touch, skipping:" "$origFileName"
    fi
  else
    echo $id "File open, skipping:" "$origFileName"
  fi
done 
else
  echo $id "No flac files found"
fi
echo $id "exiting" `date '+%F_%H:%M:%S'`

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

##test_file="/home/pi/rawRecordings/test.txt"
##echo hi there >> $test_file 

#       printf -v alttargetFileName '$(basename $interimFile _interim.aiff)'.flac -1 ;
#       echo "COMPARING:" "$alttargetFileName" 
#       echo " TO " "$targetFileName"
