#!/usr/bin/env bash

set -e

INPUT=$(kdialog --inputbox "Enter a dir or file")
[[ -z "$INPUT" ]] && exit 0

RESULTS=$(fd "$INPUT" ~ ~/.config $(echo ~/dotfiles/*/.config))

[[ -z "$RESULTS" ]] && kdialog --error "No result" && exit 0

MENU_ARGS=()
while read -r path; do
  [[ -f "$path" ]] && MENU_ARGS+=("$path" "📄$(sed "s|$HOME/VAULT/blueprints|~/:|" <<<"$path")")
  [[ -d "$path" ]] && MENU_ARGS+=("$path" "📁$(sed "s|$HOME/VAULT/blueprints|~/:|" <<<"$path")")
done <<<"$RESULTS"

SELECTED=$(kdialog --menu "_____(ZED) Found $(wc -l <<<"$RESULTS") result(s). Select one to open in ZED_____" "${MENU_ARGS[@]}")

~/.local/bin/zed "$SELECTED"
