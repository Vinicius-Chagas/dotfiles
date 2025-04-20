#!/bin/bash

# Wait for Discord to be open
while ! pgrep -x Discord; do
  sleep 1
done

# Add a delay to ensure Discord is fully initialized
sleep 5

# Open YouTube Music silently on workspace 3
hyprctl dispatch workspace 3 silent && youtube-music &

# Wait for YouTube Music to be open
while ! pgrep -x "youtube-music"; do
  sleep 1
done

# Add a delay to ensure youtube is fully initialized
sleep 2

# Resize Discord
hyprctl dispatch resizewindowpixel 30% 0%,class:"^([Dd]iscord)$"
