#!/bin/bash

CONFIG_FILE="$HOME/.config/hypr/hyprland.conf"

# Check if config file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Hyprland config file not found at $CONFIG_FILE"
    exit 1
fi

# Get the current opacity value
CURRENT_OPACITY=$(grep -E "^\s*active_opacity\s*=\s*" "$CONFIG_FILE" | awk -F'=' '{print $2}' | tr -d ' ')

# Determine the new opacity value
if [[ "$CURRENT_OPACITY" == "1" ]]; then
    NEW_OPACITY="0.5"
else
    NEW_OPACITY="1"
fi

# Update the config file
sed -i "s/^\s*active_opacity\s*=\s*[0-9.]*/active_opacity = $NEW_OPACITY/" "$CONFIG_FILE"

echo "Toggled active_opacity to $NEW_OPACITY"

# Reload Hyprland config
hyprctl reload

