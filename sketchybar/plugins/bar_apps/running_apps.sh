#!/usr/bin/env bash

# Source required files for colors and icons
source "$HOME/conf/sketchybar/colors.sh"
source "$HOME/conf/sketchybar/icons.sh"

# Cache file for running apps
CACHE_FILE="/tmp/sketchybar_running_apps_cache"
CACHE_TIMEOUT=30  # Cache for 30 seconds

# Get plugin directory
PLUGIN_DIR="${PLUGIN_DIR:-$HOME/conf/sketchybar/plugins}"

# Check if cache is valid
is_cache_valid() {
    if [ -f "$CACHE_FILE" ]; then
        local cache_age=$(($(date +%s) - $(stat -f%m "$CACHE_FILE" 2>/dev/null || echo 0)))
        [ $cache_age -lt $CACHE_TIMEOUT ]
    else
        false
    fi
}

# Get running apps (with caching)
get_running_apps() {
    if is_cache_valid; then
        cat "$CACHE_FILE"
    else
        # Run the AppleScript and cache the result
        local apps=$("$PLUGIN_DIR/bar_apps/get_running_apps.applescript" 2>/dev/null)
        echo "$apps" > "$CACHE_FILE"
        echo "$apps"
    fi
}

# Get existing running app items from sketchybar
get_existing_items() {
    sketchybar --query bar 2>/dev/null | jq -r '.items[]?' | grep "^running\." | sed 's/^running\.//' || true
}

# Check if an item exists in sketchybar
item_exists() {
    local item_name="$1"
    sketchybar --query "$item_name" &>/dev/null
}

# Check if value is in array
in_array() {
    local needle="$1"
    shift
    local item
    for item; do
        [[ "$item" == "$needle" ]] && return 0
    done
    return 1
}

# Get running apps and process them
APPS_STRING=$(get_running_apps)

# Build arrays of current apps and their IDs
CURRENT_APP_IDS=()
CURRENT_APP_NAMES=()

if [ -n "$APPS_STRING" ]; then
    IFS=',' read -r -a APPS_ARRAY <<< "$APPS_STRING"

    # Remove leading/trailing spaces and quotes
    for app in "${APPS_ARRAY[@]}"; do
        app=$(echo "$app" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//;s/^"//;s/"$//')
        if [ -n "$app" ] && [ "$app" != "missing value" ]; then
            app_id=$(echo "$app" | tr '[:upper:]' '[:lower:]' | tr ' ' '_' | tr -cd '[:alnum:]_')
            if [ -n "$app_id" ]; then
                CURRENT_APP_IDS+=("$app_id")
                CURRENT_APP_NAMES+=("$app")
            fi
        fi
    done
fi

# Get existing items
EXISTING_ITEMS=($(get_existing_items))

# Track the last running item for sequential positioning
LAST_RUNNING_ITEM="running"

# Add or update current apps
for i in "${!CURRENT_APP_IDS[@]}"; do
    app_id="${CURRENT_APP_IDS[$i]}"
    app="${CURRENT_APP_NAMES[$i]}"

    # Get appropriate icon for the app using icon_map
    icon_map "$app"
    icon="$icon_result"

    if ! item_exists "running.$app_id" && [ "$app" != "WeatherMenu" ]; then
        # Add new item first (it will appear at end)
        sketchybar --add item "running.$app_id" left \
            --set "running.$app_id" \
                icon="$icon" \
                icon.font="$NERD_FONT:Bold:24.0" \
                icon.color="$(get_color SKY 40)" \
                label="$app" \
                label.drawing=off \
                background.color="$(get_color GREY 20)" \
                background.corner_radius=8 \
                background.height=24 \
                icon.padding_left=4 \
                icon.padding_right=4 \
                padding_left=2 \
                padding_right=2 \
                click_script="$PLUGIN_DIR/bar_apps/app_focus.sh '$app'"
    fi

    # Always position the item correctly (whether new or existing)
    if [ "$app" != "WeatherMenu" ] && item_exists "running.$app_id"; then
        sketchybar --move "running.$app_id" after "$LAST_RUNNING_ITEM" 2>/dev/null || true
        LAST_RUNNING_ITEM="running.$app_id"
    fi
done

# Remove items for apps that are no longer running
for existing_item in "${EXISTING_ITEMS[@]}"; do
    if ! in_array "$existing_item" "${CURRENT_APP_IDS[@]}"; then
        # App is no longer running, remove its item
        sketchybar --remove "running.$existing_item" 2>/dev/null || true
    fi
done

# Update the main running item to show count
app_count=${#CURRENT_APP_IDS[@]}
app_count=$((app_count - 1))  # Exclude the Weather Menu
if [ $app_count -gt 0 ]; then
    sketchybar --set running \
        label="$app_count apps" \
        label.drawing=off \
        icon.color="$(get_color GREEN 100)" 2>/dev/null || true

    # Ensure bracket exists when we have apps
    if ! sketchybar --query running_apps &>/dev/null; then
        sketchybar --add bracket running_apps '/running\..*/' running \
            --set running_apps \
                background.color="$(get_color GREY 20)" \
                background.corner_radius=12 \
                background.height=28 \
                background.drawing=on 2>/dev/null || true
    fi
else
    # No apps found, update main item
    sketchybar --set running \
        label="no apps" \
        icon="󰂚" \
        icon.color="$(get_color GREY 50)" 2>/dev/null || true
fi