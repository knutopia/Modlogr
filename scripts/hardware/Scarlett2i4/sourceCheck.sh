#!/bin/bash

#Looking for Scarlett 2i4 USB

this="sourceCheck"
sourceCheck() {
  if [ -d "/proc/asound/USB" ]
  then
    echo $this "Scarlett 2i4 USB Found"
    return 0
  else
    echo $this "Scarlett 2i4 USB not found"
    return 1
  fi
}
