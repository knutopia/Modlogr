#!/bin/bash

this="sourceCheck"
sourceCheck() {
  if [ -d "/proc/asound/ES8" ]
  then
    echo $this "ES8 Found"
    return 0
  else
    echo $this "ES8 not found"
    return 1
  fi
}
