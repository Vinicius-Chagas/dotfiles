#!/bin/bash

# Get the current transform value
current_transform=$(hyprctl monitors | grep "transform" | awk '{print $2}')

# Determine the next transform value
case "$current_transform" in
  0)
    next_transform=1
    ;;
  1)
    next_transform=3
    ;;
  3)
    next_transform=0
    ;;
  *)
    next_transform=1 # Default to right if current is unknown
    ;;
esac

# Rotate the screen
hyprctl keyword monitor HDMI-A-1,1920x1080@120.00,auto,1,transform,"$next_transform"
