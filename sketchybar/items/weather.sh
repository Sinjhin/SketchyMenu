#!/usr/bin/env bash

add_weather_item() {
    local side="${1:-left}"

    sketchybar --add alias "WeatherMenu,Item-0" "$side" \
        --rename "WeatherMenu,Item-0" "weather" \
        --set "weather" \
            "${item_style[@]}" \
            icon.drawing=off \
			label.drawing=off \
            click_script="open -a Weather" \
            script="$PLUGIN_DIR/weather.sh"
}
