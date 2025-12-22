#!/usr/bin/env bash
# Usage example: ./toggle.sh firefox

if ! pgrep -x "$1" >/dev/null; then
  "$1" &
  exit
fi

ACTIVE=$(xdotool getactivewindow)
APP=$(wmctrl -lx | grep -i "$1" | awk '$2 != -1 {print $1}' | tail -n 1)

if [ -z "$APP" ]; then
  "$1" &
  exit
fi

# Convert into decimal pid
APP_DEC=$((APP))

if [ "$APP_DEC" = "$ACTIVE" ]; then
  xdotool windowminimize "$APP_DEC"
else
  xdotool windowactivate "$APP_DEC"
fi
