#!/usr/bin/env bash

add_aerospace_item() {
    local side="${1:-left}"

    # Fetch all workspace-to-monitor mappings as a space-separated string
    # Format: "1:2 2:2 3:2 4:2 5:1 6:1 7:1 8:1 9:1"
    WORKSPACE_MONITOR_MAPPINGS=$(aerospace list-workspaces --all --format "%{workspace}:%{monitor-id}" 2>/dev/null | tr '\n' ' ' || true)

    # Get the monitor ID for a given workspace
    get_monitor_for_workspace() {
        local target_workspace="$1"
        local mapping
        local workspace_num
        local monitor_id
        
        # Look through all workspace:monitor pairs
        for mapping in $WORKSPACE_MONITOR_MAPPINGS; do
            workspace_num=${mapping%:*}  # Extract workspace number (before colon)
            monitor_id=${mapping#*:}     # Extract monitor ID (after colon)
            
            if [ "$workspace_num" = "$target_workspace" ]; then
                echo "$monitor_id"
                return 0
            fi
        done
        
        # Default fallback if workspace not found in mappings:
        # - Workspaces 1-4 default to monitor 2
        # - Workspaces 5+ default to monitor 1
        if [ "$target_workspace" -le 4 ] 2>/dev/null; then 
            echo 2
        else 
            echo 1
        fi
    }

    # Static defaults if not explicitly mapped:
    # - 1..4 -> monitor 2 (external/main at home)
    # - 5..9 -> monitor 1 (built-in)
    label_for_ws() {
        case "$1" in
            5) echo "Q";;
            6) echo "W";;
            7) echo "E";;
            8) echo "R";;
            9) echo "A";;
            *) echo "$1";;
        esac
    }

    for MAPPING in $WORKSPACE_MONITOR_MAPPINGS; do
        workspace=${MAPPING%:*}
        monitor=$(get_monitor_for_workspace "$workspace")

        local item="aerospace.${monitor}.${workspace}"
        local label_for_workspace=$(label_for_ws "$workspace")

        sketchybar --add item "$item" "$side" \
            --set "$item" \
                label="$label_for_workspace" \
                label.font="$FONT:Bold:14.0" \
                label.color="$(get_color WHITE 70)" \
                label.highlight_color="$WHITE" \
                icon.drawing=off \
                background.color="$(get_color YELLOW 40)" \
                background.drawing=off \
                padding_left=2 \
                padding_right=2 \
                click_script="aerospace workspace $workspace" \
                script="$PLUGIN_DIR/aerospace.sh $monitor $workspace" \
            --subscribe "$item" aerospace_workspace_change display_change
    done

    # Create bracket for island effect (align to shared item style)
    sketchybar --add bracket aero_items '/aero\.*/' \
        --set aero_items \
            background.color="$(get_color DARK_GREEN 40)" \
            background.corner_radius=12 \
            background.height=28 \
            background.drawing=on

}
