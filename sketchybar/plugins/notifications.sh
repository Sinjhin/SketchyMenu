#!/usr/bin/env bash

# Source required files for colors and fonts
source "$HOME/conf/sketchybar/colors.sh"
source "$HOME/conf/sketchybar/icons.sh"

# Get all visible apps from dock dynamically
get_apps_from_dock() {
    osascript -e "tell application \"System Events\"
        get name of every process whose visible is true
    end tell" 2>/dev/null
}

# Simple AppleScript function to get badge count for any app
check_app_badge() {
    local app_name="$1"
    osascript -e "tell application \"System Events\" to tell process \"Dock\" to try
        return value of attribute \"AXStatusLabel\" of UI element \"$app_name\" of list 1
    on error
        return 0
    end try" 2>/dev/null
}

# Get all visible apps dynamically and parse correctly
APPS_STRING=$(get_apps_from_dock)
IFS=',' read -r -a APPS <<< "$APPS_STRING"

# Remove the single leading space
for i in "${!APPS[@]}"; do
    APPS[$i]="${APPS[$i]# }"
done

# Track if we have any notifications
HAS_NOTIFICATIONS=false
NOTIFICATION_COUNT=0

# Check all apps using AppleScript
for app in "${APPS[@]}"; do
    BADGE=$(check_app_badge "$app")

    # Handle all badge types: numbers ("1"), bullet ("•"), and missing value
    if [ -n "$BADGE" ] && [ "$BADGE" != "0" ] && [ "$BADGE" != "missing value" ]; then
        HAS_NOTIFICATIONS=true
        NOTIFICATION_COUNT=$((NOTIFICATION_COUNT + 1))

        # Create a clean identifier for the item
        app_id=$(echo "$app" | tr '[:upper:]' '[:lower:]' | tr ' ' '_')

        # Get appropriate icon for the app
        icon=$(icon_map "$app")

        # Add the notification item
        sketchybar --add item "notif.$app_id" right \
            --set "notif.$app_id" \
                icon="$icon" \
                icon.font="$NERD_FONT:Bold:30.0" \
                icon.color="$(get_color WHITE 100)" \
                label="$BADGE" \
                label.color="$(get_color RED 100)" \
                label.font="$FONT:Bold:14.0" \
                background.color="$(get_color RED 30)" \
                background.corner_radius=10 \
                background.height=24 \
                icon.padding_left=6 \
                icon.padding_right=-6 \
                padding_left=0 \
                padding_right=4 \
                click_script="open -a '$app'" \
                position=right
    else
        # Remove the item if it exists and no notifications
        app_id=$(echo "$app" | tr '[:upper:]' '[:lower:]' | tr ' ' '_')
        sketchybar --remove "notif.$app_id" 2>/dev/null
    fi
done

# Update the anchor icon based on whether we have notifications
if [ "$HAS_NOTIFICATIONS" = true ]; then
    # Show notification icon with accent color when there are notifications
    sketchybar --set $NAME.anchor \
        icon="󰂚" \
        icon.color="$(get_color GREY 100)" \
        background.color="$(get_color YELLOW 40)"
else
    # Show dimmed icon when no notifications
    sketchybar --set $NAME.anchor \
        icon="󰂜" \
        icon.color="$(get_color GREY 50)" \
        background.color="$(get_color GREY 20)"
fi