#!/usr/bin/env bash

DATE=$(date '+%Y %m %d')
TIME=$(date '+%H:%M')

# Handle both datetime items
for item in datetime datetime_center; do
    if sketchybar --query "$item" &>/dev/null; then
        position=$(sketchybar --query "$item" | jq -r '.geometry.position')
        if [ "$position" == "center" ]; then
            sketchybar --set "$item" label="${TIME}"
        elif [ "$position" == "e" ] || [ "$position" == "q" ]; then
                sketchybar --set "$item" label="${TIME}" \
                    padding_left=12 \
                    padding_right=12
        else
            sketchybar --set "$item" label="${DATE} | ${TIME}"
        fi
    fi
done