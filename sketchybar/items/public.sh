#!/usr/bin/env bash

add_public_item() {
    local side="${1:-left}"

    sketchybar --add item "public" "$side" \
        --set "public" \
            "${item_style[@]}" \
            label="0.0.0.0" \
            icon.color="$(get_color YELLOW 100)" \
            update_freq=600 \
            script="$PLUGIN_DIR/get_public_ip.sh" \
            click_script="open /System/Library/PreferencePanes/Network.prefpane" \
        --subscribe "public" wifi_change
}
