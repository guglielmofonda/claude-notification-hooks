#!/bin/bash
TAB_NAME=""

if [ "$TERM_PROGRAM" = "ghostty" ] || [ -n "$GHOSTTY_RESOURCES_DIR" ]; then
    # Walk up the process tree to find the parent shell's TTY
    parent_pid=$$
    for _ in 1 2 3 4 5 6 7 8 9 10; do
        parent_pid=$(ps -p "$parent_pid" -o ppid= 2>/dev/null | tr -d ' ')
        [ -z "$parent_pid" ] || [ "$parent_pid" -le 1 ] && break
        tty_val=$(ps -p "$parent_pid" -o tty= 2>/dev/null | tr -d ' ')
        if [ -n "$tty_val" ] && [ "$tty_val" != "??" ]; then
            tty_key="${tty_val//\//_}"
            tab_file="/tmp/ghostty_tab_${tty_key}"
            if [ -f "$tab_file" ]; then
                TAB_NAME=$(cat "$tab_file" 2>/dev/null)
            fi
            break
        fi
    done
elif [ "$TERM_PROGRAM" = "iTerm.app" ] && [ -n "$ITERM_SESSION_ID" ]; then
    TAB_NAME=$(osascript <<'APPLESCRIPT' 2>/dev/null
tell application "iTerm2"
    set sid to (system attribute "ITERM_SESSION_ID")
    repeat with w in windows
        repeat with t in tabs of w
            repeat with s in sessions of t
                if unique id of s = sid then
                    return name of t
                end if
            end repeat
        end repeat
    end repeat
end tell
APPLESCRIPT
)
elif [ "$TERM_PROGRAM" = "Apple_Terminal" ]; then
    TAB_NAME=$(osascript -e 'tell application "Terminal" to name of selected tab of front window' 2>/dev/null)
fi

if [ -n "$TAB_NAME" ]; then
    say -v Daniel "Your agent needs you at $TAB_NAME"
else
    say -v Daniel "Your agent needs you"
fi
