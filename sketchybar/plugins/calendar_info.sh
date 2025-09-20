#!/usr/bin/env bash

DATE=$(date +%Y%m%d)
# Get the next few events as a single string
FEW_NEXT_EVENTS=$(icalBuddy -n -iep -iep "title,datetime" -npn -eed -li 6 -df "%Y%m%d" -po "datetime,title" -ps "| - |" -b "" -nc "eventsToday+7")
NEXT_EVENT=$(icalBuddy -n -iep -iep "title,datetime" -npn -eed -li 1 -df "%Y%m%d" -po "datetime,title" -ps "| - |" -b "" -nc -nrd -ead "eventsToday+7")
IS_TODAY=$(if [ "$(echo $NEXT_EVENT | cut -c 1-8)" == "$DATE" ]; then echo "true"; else echo "false"; fi)

if [ $IS_TODAY == "true" ]; then
    LABEL="$(echo $NEXT_EVENT | cut -c 12-)"
else
    LABEL="Free rest of day"
fi

sketchybar --set $NAME \
    label="$LABEL"

# Clear existing popup items
for i in {1..10}; do
    sketchybar --remove $NAME.event.$i 2>/dev/null
done

# Add popup items for the next few events
if [ -n "$FEW_NEXT_EVENTS" ]; then
    counter=1
    while IFS= read -r event; do
        if [ -n "$event" ]; then
            sketchybar --add item $NAME.event.$counter popup.$NAME \
                --set $NAME.event.$counter \
                    label="$event" \
                    click_script="open -a 'Notion Calendar.app'"
            counter=$((counter + 1))
        fi
    done <<< "$FEW_NEXT_EVENTS"
fi
