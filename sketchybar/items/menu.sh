#!/usr/bin/env bash

add_menu_item() {
    local side="${1:-left}"

    # Main menu icon
    sketchybar --add item "menu" "$side" \
        --set "menu" \
        "${item_style[@]}" \
        label.font="$NERD_FONT:Bold:32.0" \
        label="" \
        label.color="$(get_color MAGENTA 100)" \
        icon.drawing=off \
        label.padding_left=5 \
        background.color="$(get_color YELLOW 40)" \
        click_script="$PLUGIN_DIR/sketchymenu/app_menu.sh"
}
