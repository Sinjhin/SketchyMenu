#!/usr/bin/env bash

add_batt_item() {
    local side="${1:-left}"

    sketchybar --add item "batt" "$side" \
        --set "batt" \
            "${item_style[@]}" \
            icon.color="$(get_color GREY 100)" \
            label.color="$(get_color GREY 100)" \
            icon.padding_left=4 \
            icon.padding_right=0 \
            label.padding_left=0 \
            label.padding_right=4 \
            script="$PLUGIN_DIR/battery.sh" \
            click_script="open /System/Library/PreferencePanes/Battery.prefPane"
}
