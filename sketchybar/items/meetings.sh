#!/usr/bin/env bash

add_meetings_item() {
	local side="${1:-right}"

	# Next and upcoming meetings
	sketchybar --add item "meetings" "$side" \
		--set "meetings" \
			"${item_style[@]}" \
			icon="󰸘" \
			label="Loading..." \
			icon.padding_right=-8 \
			label.padding_right=12 \
			update_freq=300 \
			script="$PLUGIN_DIR/calendar_info.sh" \
			click_script="sketchybar --set meetings popup.drawing=toggle"
}
