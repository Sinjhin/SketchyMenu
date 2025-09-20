#!/usr/bin/env bash

# Simple weather color buckets. Drops all that interpolation crap.

# Get full temp string like "+76°F"
raw=$(curl wttr.in/chattanooga?format=1)    # format 1 gives something like “+76°F …”
if [ -z "$raw" ]; then
    exit 1
fi

# extract number: remove everything before + or -, then take digits
temp=$(echo "$raw" | grep -Eo '[-+]?[0-9]+' || echo "0")

# For testing: uncomment this to force a value
# temp=95

# Choose color by buckets
if [ "$temp" -gt 96 ]; then
    color=0xffff0000
elif [ "$temp" -gt 90 ]; then
    color=0xffee5511
elif [ "$temp" -gt 84 ]; then
    color=0xffcc7700
elif [ "$temp" -gt 68 ]; then
    color=0xffaacc00
elif [ "$temp" -gt 60 ]; then
    color=0xff88cc00
elif [ "$temp" -gt 50 ]; then
    color=0xff66cc88
elif [ "$temp" -gt 40 ]; then
    color=0xff44ccff
elif [ "$temp" -gt 32 ]; then
    color=0xff0066ff
elif [ "$temp" -gt 20 ]; then
    color=0xff0044cc
else
    color=0xff000088
fi

# Set SketchyBar alias color & also label with temp so you can see it
sketchybar --set $NAME alias.color=$color