#!/usr/bin/env bash

# Fast SketchyBar App Menu with Submenu Support
# Loads submenus on-demand for speed

# Handle different commands
CMD="${1:-toggle}"
MENU_PATH="${2:-}"

# Get plugin directory
PLUGIN_DIR="${PLUGIN_DIR:-$HOME/conf/sketchybar/plugins}"

clear_menu() {
    sketchybar --query menu 2>/dev/null | jq -r '.popup.items[]?' | while read -r item; do
        [ -n "$item" ] && sketchybar --remove "$item" 2>/dev/null || true
    done
}

case "$CMD" in
    toggle)
        # Check state FIRST
        STATE=$(sketchybar --query menu 2>/dev/null | jq -r '.popup.drawing')
        
        if [ "$STATE" = "on" ]; then
            # Close menu
            sketchybar --set menu popup.drawing=off
            # Cleanup
            clear_menu
        else
            # Open menu and show top level
            sketchybar --set menu popup.drawing=on
            "$0" load_top
        fi
        ;;
        
    load_top)
        # Clear existing items
        clear_menu
        
        # Get current app
        APP=$(osascript -e 'tell application "System Events" to name of first application process whose frontmost is true')
        # APP=$(sketchybar --query "app" | jq '.label.value')
        
        # Get menu bar items fastest way I've found
        MENUS=$(osascript << EOF
tell application "System Events"
    tell process "$APP"
        set menuList to {}
        set idx to 0
        repeat with mb in menu bar items of menu bar 1
            try
                set menuName to name of mb
                set hasSubmenu to false
                try
                    set m to menu 1 of mb
                    set hasSubmenu to true
                end try
                if hasSubmenu then
                    set end of menuList to menuName & "|" & idx & "|Y"
                else
                    set end of menuList to menuName & "|" & idx & "|N"
                end if
            end try
            set idx to idx + 1
        end repeat
        return menuList
    end tell
end tell
EOF
)
        
        # Parse and add menu items
        i=0
        echo "$MENUS" | tr ',' '\n' | while read -r line; do
            # Parse: name|index|hasSubmenu
            IFS='|' read -r name idx has_sub <<< "$(echo "$line" | tr -d ' "')"
            
            if [ -n "$name" ] && [ "$name" != "missing" ]; then
                if [ "$has_sub" = "Y" ]; then
                    # Has submenu - add arrow
                    sketchybar --add item "menu.item.$i" popup.menu \
                        --set "menu.item.$i" \
                            label="$name ▸" \
                            icon.drawing=off \
                            click_script="$PLUGIN_DIR/sketchymenu/app_menu.sh load_sub '$idx'"
                else
                    # No submenu
                    sketchybar --add item "menu.item.$i" popup.menu \
                        --set "menu.item.$i" \
                            label="$name" \
                            icon.drawing=off \
                            click_script="echo 'Execute: $name'"
                fi
                i=$((i + 1))
            fi
        done
        ;;
        
    load_sub)
        # Load submenu items
        if [ -z "$MENU_PATH" ]; then exit 0; fi
        
        # Clear existing items
        clear_menu
        
        # Add back button
        sketchybar --add item "menu.item.back" popup.menu \
            --set "menu.item.back" \
                label="‹ Back" \
                icon.drawing=off \
                click_script="$PLUGIN_DIR/sketchymenu/app_menu.sh load_top"
        
        # Add separator
        sketchybar --add item "menu.item.sep" popup.menu \
            --set "menu.item.sep" \
                label="────────" \
                icon.drawing=off
        
        # Get submenu items for the selected menu
        APP=$(osascript -e 'tell application "System Events" to name of first application process whose frontmost is true')
        MENU_INDEX=$((MENU_PATH + 1))
        
        ITEMS=$(osascript << EOF
tell application "System Events"
    tell process "$APP"
        try
            set menuBarItem to menu bar item $MENU_INDEX of menu bar 1
            set menuItems to menu items of menu 1 of menuBarItem
            set itemList to {}
            repeat with mi in menuItems
                try
                    set itemName to name of mi
                    set itemEnabled to enabled of mi
                    if itemName is missing value then
                        set end of itemList to "---"
                    else if itemEnabled then
                        set end of itemList to itemName
                    else
                        set end of itemList to "[" & itemName & "]"
                    end if
                end try
            end repeat
            return itemList
        on error
            return {}
        end try
    end tell
end tell
EOF
)
        
        # Add submenu items
        i=2
        echo "$ITEMS" | tr ',' '\n' | while read -r item; do
            item=$(echo "$item" | tr -d '"' | xargs)
            
            if [ "$item" = "---" ]; then
                # Separator
                sketchybar --add item "menu.sub.$i" popup.menu \
                    --set "menu.sub.$i" \
                        label="────────" \
                        icon.drawing=off
            elif [ -n "$item" ]; then
                # Check if disabled (wrapped in brackets)
                if [[ "$item" == \[*\] ]]; then
                    # Disabled item
                    item=${item:1:-1}
                    sketchybar --add item "menu.sub.$i" popup.menu \
                        --set "menu.sub.$i" \
                            label="$item" \
                            label.color=0xff888888 \
                            icon.drawing=off
                else
                    # Enabled item
                    sketchybar --add item "menu.sub.$i" popup.menu \
                        --set "menu.sub.$i" \
                            label="$item" \
                            icon.drawing=off \
                            click_script="$PLUGIN_DIR/sketchymenu/click_menu_item.applescript '$APP' '$MENU_PATH/$((i-2))' && sketchybar --set menu popup.drawing=off"
                fi
            fi
            i=$((i + 1))
            if [ $i -gt 30 ]; then break; fi
        done
        ;;
esac