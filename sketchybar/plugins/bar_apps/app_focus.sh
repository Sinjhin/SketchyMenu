#!/usr/bin/env bash

source "$HOME/conf/sketchybar/colors.sh"

# App focus click handler for running apps
# Usage: app_focus.sh "App Name"

APP_NAME="$1"

if [ -z "$APP_NAME" ]; then
    echo "Usage: $0 'App Name'"
    exit 1
fi

# Focus/activate the app
open -a "$APP_NAME" 2>/dev/null

# Optional: Add visual feedback (brief highlight)
# Get the item name from the app name
app_id=$(echo "$APP_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '_' | tr -cd '[:alnum:]_')

if [ -n "$app_id" ]; then
    # Brief highlight effect
    sketchybar --set "running.$app_id" \
        background.color=$(get_color SKY 80) 2>/dev/null &

    # Reset color after brief delay
    (sleep 0.2 && sketchybar --set "running.$app_id" \
        background.color=$(get_color GREY 20) 2>/dev/null) &
fi