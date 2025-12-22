#!/usr/bin/env bash
# Application toggle script for Wayland using kdotool to minimize/activate windows
# Usage example: ./toggle.sh firefox
ACTIVE=$(kdotool getactivewindow)
APP=$(kdotool search --class "$1" | tail -n 1)
if [ -z "$APP" ]; then
    "$1" &
    exit
fi
if [ "$APP" = "$ACTIVE" ]; then
    kdotool windowminimize "$APP"
else
    kdotool windowactivate "$APP"
fi
