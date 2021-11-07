# Modlogr
*Automatic USB audio recorder on Raspberry Pi with external USB audio interface*

Record music without having to connect a full computer, DAWless. Meant to work with a modular synth or any other instrument, banning the laptop from the table. The Raspberry Pi just sits there and records, using your existing high-quality audio interface. The musician can focus on the music. Later, the files recorded by the Raspberry Pi can be transferred to the computer and dropped into a DAW or into an audio editor.

## Required Equipment
* Something to make music with
* A class-compliant USB audio interface. The project is written for the *Expert Sleepers ES8,* an audio interface in a eurorack module form factor. With some edits, the code should work with any class-compliant interface.
* A Raspberry Pi 4 or Raspberry Pi 400. Other Raspberry PI variations might work too. 
  * Since the Pi 4 is just a raw circuit board, consider getting a case for your Pi 4. (The Pi 400 is built into a keyboard case.) When choosing a case, consider that a case without a fan will be silent, whereas a case with a fan will be noisy while you are making music.
* A recent version of Raspbian, the default OS on the Raspberry Pi. The project was developed on *Raspbian GNU Linux 10 (buster)*
* A large, fast MicroSD card. An hour of recording with 4 tracks takes about 600 MiB of space as FLAC.
* A computer with a DAW (I use a Macbook Pro with Ableton Live) that can import audio files (FLAC files, specifically)
* Remote-control software on the computer to operate the Raspberry PI (see Pi documentation), like VNC Viewer. 
  * You can also connect a screen, mouse and keyboard to the Pi to operate it directly (or use the built-in keyboard of the Pi 400), but remote operation is convenient.
* File transfer software on the computer to download the recordings from the Raspberry Pi (see Pi documentation.) VNC Viewer has file transfer functionality built in, which is convenient for transferring files during a VNC session. For simple file transfer without a VNC session, consider FileZilla.

## Expected Skill Level
This is a project, not a consumer product. Don't expect everything to just work. Teach yourself to operate a Raspberry Pi, to edit files on it, to run command line actions. Many people have done this. The internet is full of great support resources.

## Basic Operation

*In short:* when the Raspberry Pi is powered on, and the audio interface is connected to it and powered on, then the Pi starts recording, and keeps recording. Turn turn off the equipment or disconnect the audio interface when you don't want it to be recording.

### Setup
1. [Install](#installation) the project
1. Connect your musical instrument to your audio interface to record it
1. Connect the USB output of your audio interface to a USB input on the Raspberry PI (######### WHICH INPUT?)
1. Restart the Raspberry Pi

### Status LED
An LED on the Raspberry Pi shows recording state:
* Slow blink (2s on, short moment off): Recording in progress
* Fast blink (4 blink per second): Not recording, no audio interface found
* Medium blink (1 blink per second): Not recording, no audio interface found, but post-processing recent recordings
* Irregular LED, mostly off (showing disk access, this is what the LED normally does): sometimes appears for a few seconds when recording has not started yet or recording has just stopped

### Recording
1. Power on your audio interface and your instrument
2. Power on the Raspberry Pi. It takes the Pi about 45 seconds to boot (15s) and then to find the audio interface (30s). During this time, the LED is on (not blinking.) Once the LED starts slow-blinking, the Pi is recording.
3. Make music
4. When done, power off your audio interface or disconnect it from the Raspberry Pi. Within ten seconds or so, the LED will start blinking rapidly, meaning the Pi noticed that the interface is missing and recording has stopped.
5. Now turn off the Raspberry Pi, or give it time to finish processing raw recordings first. 
* Processing starts a little while after recording stops. 
* While processing, the LED blinks at medium speed. 
* Processing takes about two minutes per hour of raw recordings with 4 tracks.
* After processing is done, the LED goes inactive, flickering occasionally. Now your most recent recording has been processed and is available for download.
* Turn off the Raspberry Pi or connect your computer to transfer the recording.

#### Powering Down the Pi During Recording or Processing
If you turn off the Raspberry Pi while it is recording, the recording simply stops. Next time you turn on the Pi, any raw recordings, including this latest recording, will be processed. 

If you turn off the Pi *without* giving it time to process recent recordings, or while it is processing recordings, the processing of raw recordings will restart  the next time you power up the Pi.

### Transferring Files
1. On your computer, connect to the Pi using your file transfer software
2. In the file transfer software, navigate to the Processed Recordings folderon the Pi.
3. Transfer the recordings you want to your computer
4. On your computer, import the transferred files into your DAW. 
5. in the file transfer software, delete the processed recording you just transferred from the Raspberry Pi, to free up space. Aslo delete other recordings that you don't plan to use.
 
* Files can be transferred to the computer while recording is happening. 
* Only past recordings that have been processed are available for transfer in the *Processed Recordings* folder. 
* If recording is currently active, the current recording must stop and be processed before it becomes available for transfer.

## How it Works
After the Raspberry Pi has booted, it waits 30 seconds and then starts looking for an audio interface. The 30 seconds delay give the USB connection time to get ready - the value is found experimentally. If the Pi finds the audio interface, it starts recording, and keeps recording as long as the interface is there (and powered on) and as long as the Raspberry Pi is running. Look for the LED to start blinking slowly when recording starts.

Recording is happening the entire time the Pi and the Audio Interface are running, regardless of you making any music or not. 

When the audio interface is powered off, recording ends. With the audio interface off, the Pi starts looking for the audio interface again. As soon as it finds it (after you power up the interface again), recording resumes, to a new set of files.

The raw recordings are Flac files, which have lossless compression, taking up about half the space of an uncompressed audio file. There is one file per track. 

Before being ready for the DAW on the computer, the raw recordings need to be processed. This happens in the background. Whenever there is a set of raw recording files sitting in the *Raw Recordings* folder that is no longer being recorded to, those files are processed. When processing is done, after the processed files are saved to the *Processed Recordings* folder, the corresponing raw files are deleted.

### Why Is Processing Necessary?
In theory, the raw recordings could go straight into a DAW. In practice though, when recording stops, the raw file is left with incomplete metadata and Ableton rejects it when importing. Processing fixes the metadata.

Raw files can also become very large, for very long recordings (when recording over night, for example.)  Very long recordings are awkward to handle in a DAW. The resulting files can be too large for a DAW to open. (There appears to be a size limit corresponding to the max size of a WAV file, which is a standard uncompressed audio format.) 

Processing splits the raw recordings into one-hour chunks. Those chunks can be spliced seamlessly in the DAW, and uninteresting parts of long recordings can be easily discarded.

### Behind the Scenes
Overall operations are controlled by the *Monit* utility, which (you guessed it) monitors resources and processes, as defined in the *monitrc* file. Monit looks for the audio interface, launches and terminates recording, launches processing, and orchestrates updates to the LED. Monit also watches available disk space, and trims the log files when they become too large. To do all this, Monit calls bash shell scripts, as processes (running in the background), or as programs (running in the foreground.) The scripts use .pid files to keep track of running processes.

Recording and processing is done using the *ffmpeg* command, a powerful recording utility, accessing the audio interface via the *ALSA* audio system. While recording, the audio is also passed back to the audio interface for playback to provide visual feedback on the LEDs of the ES8 interface. In theory, this output could be used for audio monitoring through the ES8, but in practice the latency is far too high.

Raw recording files, processed recordings, and interim files (during processing) live in their own subfolders. Processed recordings are grouped together in subfolders per recording session. Files are named by track number and by recording date- and timestamp.

## Using Other Audio Interfaces
Some files need to be modified to work with a specific audio iterfaces. 

Check */home/pi/Modlogr/scripts/hardware* to see if there is a sundirectory with pre-made files for your interface. To use these files, copy the script files *(.sh)* from the subdirectory into */home/pi/Modlogr/scripts* and copy *monitrc* to */etc/monit/*

If there are no matching files for your interface, you can do the modifications yourself:
* Getting information about a connected audio interface: 
** If you have installed Modlogr already, shut it down: on the command line, run *sudo monit stop all*
** On the command line, run *arecord --dump-hw-params -D hw:1,0* to get information about the audio interface. You will see the name, the recording format and the sampling rate.
** Using the file browser, navigate to /proc/asound/ and look for a the subdirectory representing the audio interface (ES-8, USB, MODULAR, THR10, or similar.)
* in recordAudio.sh, nodify the ffmpeg command parameters modified to match the channel count, sampling rate and data format of the interface. Review the ffmpeg online documentation. 
* in */etc/monit/monitrc*, in the *AudioInterface* section, modify the directory name to match.
* in *sourceCheck.sh*, modify the interface directory name to match.
* in */etc/monit/monitrc*, it might also be necessary to modify the 20% CPU threshold for the *ffmpegStreamRecorder* process to adjust to the actual processor load incurred by a specific interface.

## Files & Locations
Log files in */home/pi/Modlogr/logs*
* *monit.log,* capturing output from monit and from bash scripts running as programs from monit
* *logster.log,* capturing output from bash scripts running as processes
* *recordings.log,* capturing date- and timestamps for raw recordings
* *sourceCheck.log,* capturing if the audio interface has been found when looking for it, with date- and timestamp

*/etc/monit/monitrc* is the monit control file

Bash script files in */home/pi/Modlogr/scripts*
* *install.sh* moves the *monitrc* file into */etc/monit* where the monit utility expects it
* *starter.sh* starts recording audio
* *recordAudio.sh* contains the ffmpeg call doing the actual recording, with hardware-specific parameters
* *stopper.sh* stops recording by sending a SIGTERM signal to the recording process
* *processRawAudio.sh* processes raw audio files, splitting into 1-hour aiff files and then resaving as flac, grouped in subfolders
* *processStepOne.sh* is called by processRawAudio.sh to split raw audio files into chunks
* *processStepTwo.sh* is called by processRawAudio.sh to re-save the smaller audio files
* *sourceCheck.sh* checks availability of audio interface
* *isRecordingActive* checks if the recording process is running, used by starter.sh and by LEDhandler.sh
* *LEDhandler.sh* updates the status LED
* *mindLogFolderSize* checks the size of */home/pi/Modlogr/logs* and trims the log files when the size gets too large 
* *deleteOldRecordings.sh* (not used yet:) will delete the oldest subfolder of recordings in /home/pi/processedRecordings to free up disk space

Directories for Recordings
* Raw recordings are saved in */home/pi/Modlogr/rawRecordings/*
* Processed recordings are saved in subfolders under */home/pi/Modlogr/processedRecordings*
* A utility folder is used for temporary files during processing: */home/pi/Modlogr/processingRecordings*

## <a name="installation">Installation</a>
Access the GUI on your Pi locally or through VNC viewer to follow these steps.

1. From the Pi terminal, install the Monit utility:  
pi@raspberrypi:~ $ **sudo apt-get install monit**
2. In the chromium web browser on the Pi, download the project:  
On https://github.com/knutopia/Modlogr click **Download ZIP** in the green **Code** menu
3. In the Pi file manager, locate the download **Modlogr-main.zip** in the Downloads folder (/home/pi/Downloads).  Right-click the downloaded file and select **Extract To...** in the menu.  Choose **Home** as the destination (in the top-right corner of the dialog) and **Extract** the archive.
4. In the Pi file manager, locate the **Modlogt-main** folder that the unzip operation created in /home/pi.  Right-click the folder name and select **Rename** in the menu.  Rename the folder to **Modlogr**
5. In the Pi file manager, navigate to the **scripts** folder inside Modlogr (/home/pi/Modlogr/scripts).
6. In the Pi file manager, looking at the contents of the **scripts** folder, open the **Tools** menu in the menu bar and choose **Open Current Folder in Terminal**.
7. In the new terminal, run the install.sh script:  
pi@raspberrypi:~ $ **./install.sh**  
8. Connect your USB audio interface.
9. Restart the Raspberry Pi.


<img alt="Raspberry Pi sitting on top of a Eurorack system" src="https://user-images.githubusercontent.com/2887520/135940634-22b9cef5-9f3f-4373-aa45-aaf08784f18e.jpg" width=50%>
