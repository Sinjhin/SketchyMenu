#!/bin/bash

# Usage:
#   aerospace.sh <monitor> <workspace>

MONITOR="$1" # This is from the item name, might be outdated
WORKSPACE="$2"

# Find the ACTUAL current monitor for this workspace
CURRENT_MONITOR=$(aerospace list-workspaces --all --format "%{monitor-id}:%{workspace}" | grep ":$WORKSPACE" | cut -d: -f1)

# If we couldn't find it, fall back to the original
if [ -z "$CURRENT_MONITOR" ]; then
    CURRENT_MONITOR="$MONITOR"
    RENAME="yes"
fi

# Get the number of monitors
NUM_MONITORS=$(aerospace list-monitors --count)

# Collect all visible workspaces across all monitors
VISIBLE_WORKSPACES=""
for i in $(seq 1 $NUM_MONITORS); do
  VISIBLE_WS=$(aerospace list-workspaces --visible --monitor $i)
  VISIBLE_WORKSPACES="$VISIBLE_WORKSPACES $VISIBLE_WS"
done

# Check if this workspace is currently visible
if [[ " $VISIBLE_WORKSPACES " == *" $WORKSPACE "* ]]; then
  sketchybar --set "$NAME" background.drawing=on
  sketchybar --set "$NAME" associated_display="$CURRENT_MONITOR"
  if [ "$(echo $NAME | cut -d. -f2)" != "$CURRENT_MONITOR" ]; then
      sketchybar --rename "$NAME" "aerospace.${CURRENT_MONITOR}.${WORKSPACE}"
  fi
else
  sketchybar --set "$NAME" background.drawing=off
  sketchybar --set "$NAME" associated_display="$CURRENT_MONITOR"
  if [ "$(echo $NAME | cut -d. -f2)" != "$CURRENT_MONITOR" ]; then
      sketchybar --rename "$NAME" "aerospace.${CURRENT_MONITOR}.${WORKSPACE}"
  fi
fi
