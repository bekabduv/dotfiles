#!/bin/bash
# Displays a countdown animation with colored progress bar for system shutdown

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

get_terminal_width() {
  tput cols
}

draw_progress() {
  local current=$1
  local total=$2
  local message=$3

  local term_width=$(get_terminal_width)
  local message_len=${#message}
  local time_indicator=" ${current}s "
  local time_len=${#time_indicator}

  # Leave some margin
  local available=$((term_width - message_len - time_len - 4))
  [ $available -lt 10 ] && available=10

  local progress=$((available * (total - current) / total))
  local remaining=$((available - progress))

  # Choose color based on time remaining
  local color=$GREEN
  [ $current -le 5 ] && color=$YELLOW
  [ $current -le 3 ] && color=$RED

  # Build bar with block characters for smoother look
  local bar=""
  for ((i = 0; i < progress; i++)); do
    bar+="█"
  done
  for ((i = 0; i < remaining; i++)); do
    bar+="░"
  done

  printf "\r%s ${color}[%s]${NC}%s" "$message" "$bar" "$time_indicator"
}

# Main script
echo "Pushing to git..."
# git push

echo ""
for i in {10..1}; do
  draw_progress "$i" 10 "Shutting down in"
  sleep 1
done
