#!/usr/bin/env bash

add_running_item() {
    local side="${1:-left}"

    sketchybar --add item "running" "$side" \
        --set "running" \
            "${item_style[@]}" \
            label="menu bar 2 apps" \
            label.drawing=off \
            icon="󰣇" \
            icon.padding_right=6 \
            icon.color="$(get_color YELLOW 100)" \
            update_freq=20 \
            script="$PLUGIN_DIR/bar_apps/running_apps.sh"

    # Create bracket for running apps island effect
    sketchybar --add bracket running_apps '/running\..*/' running \
        --set running_apps \
            background.color="$(get_color GREY 20)" \
            background.corner_radius=12 \
            background.height=28 \
            background.drawing=on
}
