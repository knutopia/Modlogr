# Modulog
This project turns a Raspberry Pi into an automatic USB audio recorder. The purpose of this is to be able to record music on a modular synthesizer without having to connect a computer and without having to interact with a DAW on the computer. The Raspberry Pi just sits there and records, and the musician can focus on the music. Later, the files recorded by the Raspberry Pi can be transferred to the computer and dropped into a DAW for further processing and mastering.
Of course this works for any instrument recorded with a USB audio interface, not just for a modular synthesizer. 

## Required Equipment
* Something to make music with
* A class-compliant USB audio interface. The project is written for the Expert Sleepers ES8, an audio interface in a eurorack module form factor. With some edits, the code should work with any class-compliant interface.
* A Raspberry Pi 400. Other Raspberry PI variations should work too, specifically a Raspberry Pi 4, which is basically what is inside a Pi 400. 
  * Since the Raspberry Pi 400 is built into its own keyboard, but other Pi versions are just a raw circuit board, consider getting a case for your Pi unless it is a Pi 400. When choosing a case, consider that a case without a fan will be silent, whereas a case with a fan will be noisy while you are making music.
* A recent version of Raspbian, the default OS on the Raspberry Pi. I am using "Raspbian GNU Linux 10 (buster)" 
* A large, fast MicroSD card. An hour of recording with 4 tracks takes about 600 MiB of space as FLAC.
* A computer with a DAW (I use a Macbook Pro with Ableton Live) that can import audio files (FLAC files, specifically)
* Remote-control software on the computer to operate the Raspberry PI (see Pi documentation), like VNC Viewer. 
  * You can also connect a screen, mouse and keyboard to the Pi to operate it directly (or use the built-in keyboard of the Pi 400), but remote operation is convenient.
* File transfer software on the computer to download the recordings from the Raspberry Pi (see Pi documentation), like FileZilla.

## Expected Skill Level
This is a coding project, not a consumer product. Teach yourself to operate a Raspberry Pi, to edit files on it, to run command line actions. Many people have done this. The internet is full of great support resources. *The ugly stuff:* Don't expect everything to just work. Don't ask me to fix your problems. Using this project is a privilege, not a right.

## Basic Operation

### Setup
1. Install the project
1. Connect your musical instrument to your audio interface to record it
1. Connect the USB output of your audio interface to a USB input on the Raspberry PI (######### WHICH INPUT?)
1. Restart the Raspberry Pi

### Status LED
An LED on the Raspberry Pi shows recording state:
* Slow blink: Recording in progress
* Fast blink: Not recording, no audio interface found
* Medium blink: Not recording, no audio interface found, but post-processing recent recordings
* Irregular LED (showing disk access, this is what the LED normally does): ###### ???? 

### Recording
1. Power on your audio interface and your instrument
2. Power on the Raspberry PiMake music
3. When done, power off your audio interface or disconnect it from the Raspberry Pi. Within ten seconds or so, the LED will start blinking rapidly. 
4. Now turn off the Raspberry Pi, or give it time to finish processing raw recordings first. 
* Processing starts a little while after recording stops. 
* While processing, the LED blinks at medium speed. 
* Processing takes about two minutes per hour of raw recordings with 4 tracks.
* After processing is done, the LED goes inactive, flickering occasionally. Now your most recent recording has been processed and is available for download.
* Turn off the Raspberry Pi or connect your computer to transfer the recording.
* If you turn off the Raspberry Pi *without* giving it time to process the most recent recording, it will process it the next time you power up the Pi.

### Transferring Files
1. Power on the Raspberry Pi
2. On your computer, connect to the Pi using your file transfer software
3. In the file transfer software, navigate to the Processed Recordings folder
4. Transfer the recordings you want to your computer
5. On your computer, import the transferred files into your DAW. 
6. Consider deleting the processed recording from the Raspberry Pi after transferring it, to free up space.
7. When done, turn off the Raspberry Pi. 
 
Files can be transferred while recording is happening or not. Only past recordings that have been processed are available for transfer in the Processed Recordings folder. If recording is currently active, the current recording must stop and be processed before it becomes available for transfer.

## How it Works
As soon as the Raspberry Pi has booted, it starts looking for an audio interface. If it finds one, it starts recording, and keeps recording as long as the interface is there (and powered on) and as long as the Raspberry Pi is running. Look for the LED to start blinking slowly when recording starts.

Recording is happening the entire time the Pi and the Audio Interface are running, regardless of you making any music or not. 

When you are done making music, power off your audio interface, to end the recording. Leave the Pi running to let it process the just-finished recording or power it down, to process the recording next time.

With the audio interface off, the Pi starts looking for the audio interface again. As soon as it finds it (after you power up the interface again), recording resumes in a new set of files.

The raw recordings are Flac files, which have lossless compression, taking up about half the space of an uncompressed audio file. There is one file per track. Before being ready for the DAW on the computer, the raw recordings need to be processed. This happens in the background. Whenever there is a set of raw recording files that is no longer being recorded to, those files are processed. When processing is done, the processed files replace the raw files.

### Why Is Processing Necessary?
In theory, the raw recordings could go straight into a DAW. In practice though, when recording stops, the raw file is left with incomplete metadata and Ableton rejects it when importing. Processing fixes the metadata.

Raw files can also become very large, for very long recordings (when recording over night, for example.)  Very long recordings are awkward to handle in a DAW. The resulting files can be too large for a DAW to open. (There appears to be a size limit corresponding to the max size of a WAV file, which is a standard uncompressed audio format.) 

Processing splits the raw recordings into one-hour chunks. Those chunks can be spliced seamlessly in the DAW, and uninteresting parts of long recordings can be easily discarded.

### Behind the Scenes
Overall operations are controlled by the Monit utility, which (you guessed it) monitors resources and processes, as defined in the monitrc file. Monit looks for the audio interface, launches and terminates recording, launches processing, and orchestrates updates to the LED. Monit also watches available disk space. To do all this, Monit calls bash shell scripts, as processes (running in the background), or as programs (running in the foreground.) The scripts use .pid files to keep track of running processes. #### STATUS STUFF ##### DELETING STUFF?

Recording and processing is done using the ffmpeg command, a powerful recording utility, accessing the audio interface via the ALSA audio system. While recording, the audio is also passed back to the audio interface for playback to provide visual feedback on the LEDs of the ES8 interface. In theory, this output could be used for audio monitoring through the ES8, but in practice the latency is far too high.

Raw recording files, processed recordings, and interim files (during processing) live in their own subfolders. Processed recordings are grouped together in subfolders per recording session. Files are named by track number and by recording date- and timestamp.

## Using Other Audio Interfaces
The ffmpeg command parameters need to be modified when other audio interfaces are used. The parameters can be counterintuitive. For example, the ES8 interface, while recording 4 channels, actually transmits 8 channels, and while the recording is done in 24bit format, it is actually delivered as 32bit, 
As you will learn when reviewing ffmpeg documentation, the parameter sequence consists of a set of source parameters, and one or more sets of destination parameters. ####Review Language. #####Add file handling description

## Files & Locations
Log files in /home/pi/
* monit.log, capturing output from monit and from bash scripts running as programs from monit
* logster.log, capturing output from bash scripts running as processes
* recordings.log, capturing date- and timestamps for raw recordings
* sourceCheck.log, capturing if the audio interface has been found when looking for it, with date- and timestamp

/etc/monit/monitrc Is the the monit control file

Bash script files in /usr/local/bin/
* starter.sh starts recording audio
* stopper.sh stops recording by sending a SIGTERM signal to the recording process
* sourceCheck.sh checks availability of audio interfaceisRecordingActive checks if the recording process is running, used by starter.sh and by LEDhandler.sh
* LEDhandler.sh updates the status LEDprocessRawAudio.sh processes raw audio files, splitting into 1-hour aiff files and then resaving as flac, grouped in subfolders
* deleteOldRecordings.sh (not used yet:) will delete the oldest subfolder of recordings in /home/pi/processedRecordings to free up disk space

Directories for Recordings
* Raw recordings are saved in /home/pi/rawRecordings/
* Processed recordings are saved in subfolders under /home/pi/processedRecordings
* A utility folder is used for temporary files during processing: /home/pi/processingRecordings

Installation
#######
