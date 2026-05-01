#!/usr/bin/env bash

DIR=$(kdialog --inputbox "SERVE A DIRECTORY OR FILE")
[ -z "$DIR" ] && exit 0

# Search for both files AND directories
RESULTS=$(fd "$DIR" ~ ~/.config $(echo ~/dotfiles/*/.config))
# RESULTS=$(fd --hidden --max-depth 4 "$DIR" ~)

# Exit if no results
[ -z "$RESULTS" ] && kdialog --error "Not Found" && exit 0

#Create kdialog menu
OPTIONS=()
while read -r path; do
  [[ -d "$path" ]] && OPTIONS+=("$path" "📁$(sed "s|$HOME/VAULT/blueprints|~/:|" <<<"$path")")
  [[ -f "$path" ]] && OPTIONS+=("$path" "📄$(sed "s|$HOME/VAULT/blueprints|~/:|" <<<"$path")")
done <<<"$RESULTS"

# Display OPTIONS
SELECTED=$(kdialog --menu "__________Found $(echo "$RESULTS" | wc -l) results. Select one:__________" "${OPTIONS[@]}")

[ -z "$SELECTED" ] && exit 0

thunar "$SELECTED"
