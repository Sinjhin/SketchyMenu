#!/usr/bin/env bash

# Click toggles isolation mode, but you have to set this up as a network location prior.

set -e

# Determine base item (strip .tx/.rx if clicked on those overlays)
base="$NAME"
case "$NAME" in
  *.tx|*.rx) base="${NAME%.*}" ;;
esac

# Flip labels on the visible stacked items so it’s obvious
current=$(sketchybar --query "${base}" 2>/dev/null | jq -r '.label.value // ""')
if [ "$current" = "􀑓" ]; then
  sketchybar --set "${base}" label=""
  networksetup -setairportpower en1 on
  networksetup -switchtolocation Automatic
else
  sketchybar --set "${base}" label="􀑓"
  networksetup -setairportpower en1 off
  networksetup -switchtolocation Isolated
fi
