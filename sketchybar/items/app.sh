#!/usr/bin/env bash

add_app_item() {
	local side="${1:-left}"

	sketchybar --add item "app" "$side" \
		--set "app" \
		"${item_style[@]}" \
		icon="" \
		icon.font="$NERD_FONT:Bold:32.0" \
		icon.padding_right=-4 \
		icon.padding_left=0 \
		icon.color="$(get_color GREEN 100)" \
		script="$PLUGIN_DIR/front_app.sh" \
		--subscribe "app" "front_app_switched"
}
