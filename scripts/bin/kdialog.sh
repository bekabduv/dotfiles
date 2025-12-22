#!/usr/bin/env bash

# Exit on error
set -e

# Ask user for directory name
DIR=$(kdialog --inputbox 'Enter directory/file name to search:')
[ -z "$DIR" ] && exit 0

# Search for both files AND directories -L or --follow to follow symlinks
RESULTS=$(fd "$DIR" ~ ~/.config $(echo ~/dotfiles/*/.config))

# Exit if no results
[ -z "$RESULTS" ] && kdialog --error "Not Found" && exit 0

COUNT=$(echo "$RESULTS" | wc -l)

# Build menu with type indicator
MENU_ARGS=()
while read -r path; do
  display_path="${path/#$HOME/\~}"
  display_path="${display_path/VAULT\/blueprints/[:]}"
  [[ -d "$path" ]] && MENU_ARGS+=("$path" "📁 $display_path")
  [[ -f "$path" ]] && MENU_ARGS+=("$path" "📄 $display_path")
done <<<"$RESULTS"

SELECTED=$(kdialog --menu "__________Found $COUNT results. Select one: __________" "${MENU_ARGS[@]}")
[ -z "$SELECTED" ] && exit 0

# Open appropriately based on what was selected
[ -d "$SELECTED" ] && kitty --directory="$SELECTED" nvim
[ -f "$SELECTED" ] && kitty -e nvim "$SELECTED"
