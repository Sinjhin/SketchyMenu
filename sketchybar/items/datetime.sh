#!/usr/bin/env bash

add_datetime_item() {
	local side="${1:-right}"

	# Create different item names based on position
	local item_name="datetime"
	if [ "$side" == "center" ] || [ "$side" == "e" ] || [ "$side" == "q" ]; then
		item_name="datetime_center"
	fi

	# Date and Time combined in one item
	sketchybar --add item "$item_name" "$side" \
		--set "$item_name" \
			"${item_style[@]}" \
			icon="󰃰" \
			icon.drawing=off \
			label="Loading..." \
			update_freq=30 \
			script="$PLUGIN_DIR/datetime.sh" \
			click_script="open -a 'Notion Calendar.app'"

	# Subscribe to time changes
	sketchybar --subscribe "$item_name" system_woke
}