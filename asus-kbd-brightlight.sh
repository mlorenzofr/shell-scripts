#!/bin/bash

# In Asus laptops the keyboard bright level is reprensented as value between
# 1-3 accesible trought /sys/ subsystem
#
# The file must be writeable by the user or use this command with sudo
file=/sys/class/leds/asus::kbd_backlight/brightness

if [[ ${1} =~ ^[\+\-]$ ]]; then
  bright=$(expr $(cat $file) ${1} 1)
  if [ ${bright} -lt 0 ]; then
    bright=0
  elif [ ${bright} -gt 3 ]; then
    bright=3
  fi
  echo ${bright} > ${file}
else
  echo "Usage: ${0} [+|-]"
  echo "Increase (+) or Decrease (-) the bright level for the keyboard in Asus laptops"
fi
