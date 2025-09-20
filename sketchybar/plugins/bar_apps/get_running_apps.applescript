#!/usr/bin/env osascript

-- Optimized script to get menu bar apps (based on working_but_long.applescript)
-- Returns comma-separated list of app names that have menu bar 2
tell application "System Events"
    set menuBarApps to {}

    repeat with proc in (every process)
        try
            if exists menu bar 2 of proc then
                set end of menuBarApps to (name of proc)
            end if
        end try
    end repeat

    return menuBarApps
end tell