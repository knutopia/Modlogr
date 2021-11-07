#!/bin/bash

#Looking for Yamaha THR10

this="sourceCheck"
sourceCheck() {
  if [ -d "/proc/asound/THR10" ]
  then
    echo $this "Yamaha THR10 Found"
    return 0
  else
    echo $this "Yamaha THR10 not found"
    return 1
  fi
}
