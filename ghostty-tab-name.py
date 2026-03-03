#!/usr/bin/env python3
"""
Given a marker string, write it to the parent TTY, then use System Events
to find which Ghostty window updated — returning that window's original title.
"""
import sys, subprocess, re, os, time

def get_ghostty_titles():
    script = (
        'tell application "System Events"\n'
        '    tell process "Ghostty"\n'
        '        set titleList to title of every window\n'
        '        set AppleScript\'s text item delimiters to linefeed\n'
        '        return titleList as text\n'
        '    end tell\n'
        'end tell'
    )
    r = subprocess.run(['osascript', '-e', script], capture_output=True, text=True)
    return r.stdout.strip().splitlines()

def main():
    parent_tty = sys.argv[1]   # e.g. /dev/ttys006

    before = get_ghostty_titles()
    if not before:
        sys.exit(1)

    marker = f"__CLAUDE_{os.getpid()}__"

    # Write marker — Ghostty will update this window's title
    with open(parent_tty, 'w') as tty:
        tty.write(f'\x1b]0;{marker}\x07')

    time.sleep(0.2)

    after = get_ghostty_titles()

    # Find which window changed to our marker
    tab_name = ""
    for i, title in enumerate(after):
        if title.strip() == marker and i < len(before):
            # Strip leading non-word chars (braille spinners, ✳, etc.)
            tab_name = re.sub(r'^[^\w]+', '', before[i]).strip()
            break

    # Restore the original title (shell integration will reset it at next prompt anyway)
    if tab_name:
        with open(parent_tty, 'w') as tty:
            tty.write(f'\x1b]0;{tab_name}\x07')

    print(tab_name)

if __name__ == '__main__':
    main()
