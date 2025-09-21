#!/usr/bin/env bash

NET_WIDTH=76

tx=(
    icon="􂙧"
    icon.drawing=on
    icon.font="$NERD_FONT:Italics:10"
    icon.color="$(get_color GREY 80)"
    label.drawing=on
    label='0000.00'
    label.font="$FONT:Semibold:10"
    width=0
    padding_left=-$(($NET_WIDTH - 8))
    label.padding_left=0
    label.padding_right=0
    icon.padding_left=0
    icon.padding_right=4
    y_offset=7
)

rx=(
    icon="􂙪"
    icon.drawing=on
    icon.font="$NERD_FONT:Italics:10"
    icon.color="$(get_color GREY 80)"
    label.drawing=on
    label='0000.00'
    label.font="$FONT:Semibold:10"
    width=0
    padding_left=-$(($NET_WIDTH - 8))
    label.padding_left=0
    label.padding_right=0
    icon.padding_left=0
    icon.padding_right=4
    y_offset=-6
)

NET_LOCATION=$(networksetup -getcurrentlocation)
if [ "$NET_LOCATION" = "Isolated" ]; then
    NET_LABEL="􀑓"
else
    NET_LABEL=""
fi

add_net_item() {
    local side="${1:-left}"

    sketchybar \
        --add item "net" "$side" \
        --set "net" \
            "${item_style[@]}" \
            label="$NET_LABEL" \
            label.drawing=on \
            label.padding_left=5 \
            label.color="$(get_color RED 80)" \
            width=$NET_WIDTH \
            update_freq=1 \
            script="$PLUGIN_DIR/net/network_stats.sh" \
            click_script="$PLUGIN_DIR/net/toggle_airplane.sh" \
        --add item "net.tx" "$side" \
        --set "net.tx" \
            "${tx[@]}" \
        --add item "net.rx" "$side" \
        --set "net.rx" \
            "${rx[@]}"
}
