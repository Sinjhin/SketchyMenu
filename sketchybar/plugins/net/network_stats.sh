#!/usr/bin/env bash

source "$HOME/conf/sketchybar/colors.sh"
set -e

# Computes total TX/RX Mbps across all interfaces and updates
# stacked labels: "$NAME.tx" (top, 0000.00) and "$NAME.rx" (bottom, 0000.00)

state_file="/tmp/sketchybar_net_state"

read_bytes_total() {
    # Output: RXbytes TXbytes across all non-loopback interfaces
    # Sum unique interface names using only Link# rows to avoid double counting
    netstat -ib 2>/dev/null \
        | awk '/Link#/ && $1!="lo0" { if (!seen[$1]++) { rx+=$7; tx+=$10 } } END { if(rx=="") rx=0; if(tx=="") tx=0; print rx, tx }'
}

format_val() {
    awk -v v="${1:-0}" 'BEGIN { v+=0; if (v>9999.99) v=9999.99; printf "%07.2f", v }'
}

now_ts=$(date +%s)
read -r now_rx now_tx < <(read_bytes_total)

prev_ts=0
prev_rx=$now_rx
prev_tx=$now_tx
if [ -f "$state_file" ]; then
    read -r prev_ts prev_rx prev_tx < "$state_file" || true
fi

# Reset baseline if timestamp missing
if [ -z "${prev_ts:-}" ]; then
    prev_ts=$now_ts
    prev_rx=$now_rx
    prev_tx=$now_tx
fi

dt=$(( now_ts - prev_ts ))
if [ "$dt" -le 0 ]; then
    dt=1
fi

rx_diff=$(( now_rx > prev_rx ? now_rx - prev_rx : 0 ))
tx_diff=$(( now_tx > prev_tx ? now_tx - prev_tx : 0 ))

# Convert bytes/sec -> Mbps (decimal megabits)
rx_mbps=$(awk -v b="$rx_diff" -v dt="$dt" 'BEGIN { printf "%.2f", (b*8)/(1000000*dt) }')
tx_mbps=$(awk -v b="$tx_diff" -v dt="$dt" 'BEGIN { printf "%.2f", (b*8)/(1000000*dt) }')

tx_label=$(format_val "$tx_mbps")
rx_label=$(format_val "$rx_mbps")

# Persist current snapshot for next run
printf "%s %s %s\n" "$now_ts" "$now_rx" "$now_tx" > "$state_file"

# Update stacked items: ensure TX on top, RX on bottom
# Dynamic icon colors: default GREY 80; highlight when > 0.00
GREY80=$(get_color GREY 80)
YELLOW100=$(get_color YELLOW 100)
LIME100=$(get_color LIME 100)

tx_color=$GREY80
rx_color=$GREY80

awk -v v="$tx_mbps" 'BEGIN { exit !(v>0) }' && tx_color=$YELLOW100 || true
awk -v v="$rx_mbps" 'BEGIN { exit !(v>0) }' && rx_color=$LIME100 || true

# PoC guard: if user toggled labels to 'air'/'wifi', do not overwrite
poctag=$(sketchybar --query "$NAME.tx" 2>/dev/null | jq -r '.label.value // ""')
if [ "$poctag" = "air" ] || [ "$poctag" = "wifi" ]; then
    exit 0
fi

sketchybar \
    --set "$NAME.tx" label="$tx_label" icon.color=$tx_color \
    --set "$NAME.rx" label="$rx_label" icon.color=$rx_color
