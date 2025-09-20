#!/usr/bin/env bash

add_notifs_item() {
    local side="${1:-right}"

    # Main notification center anchor/container
    sketchybar --add item notifs.anchor "$side" \
        --set notifs.anchor \
            "${item_style[@]}" \
            icon="󰂚" \
            icon.font="$NERD_FONT:Bold:24.0" \
            icon.color="$(get_color BLUE 60)" \
            label.drawing=off \
            background.color="$(get_color GREY 20)" \
            background.corner_radius=12 \
            background.height=28 \
            icon.padding_left=8 \
            icon.padding_right=8 \
            padding_right=4 \
            script="$PLUGIN_DIR/notifications.sh" \
            click_script="open /System/Library/PreferencePanes/Notifications.prefpane" \
            update_freq=4

    # Subscribe to events for dynamic updates
    sketchybar --subscribe notifs.anchor system_woke
}