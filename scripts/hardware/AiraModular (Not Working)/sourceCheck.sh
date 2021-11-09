#!/bin/bash

# Modlogr: automatic headless USB audio recorder on Raspberry Pi with external USB audio interface
#    Copyright (C) 2021  Knut Graf
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

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
