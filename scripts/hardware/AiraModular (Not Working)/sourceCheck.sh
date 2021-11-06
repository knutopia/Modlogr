#!/bin/bash

#Looking for Roland AIRA Modular (made with Torcido, probably works for the others)

this="sourceCheck"
sourceCheck() {
  if [ -d "/proc/asound/MODULAR" ]
  then
    echo $this "AIRA Modular Found"
    return 0
  else
    echo $this "AIRA Modular not found"
    return 1
  fi
}
