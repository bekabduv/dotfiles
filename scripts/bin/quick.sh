#!/usr/bin/env bash
# Quick development server launcher that detects package manager and serves files/directories

# Exit on error
set -e

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

# Start serving
BUN_DEV="cd $SELECTED && bun dev; exec zsh"
PNPM_DEV="cd $SELECTED && pnpm run dev; exec zsh"
NPM_DEV="cd $SELECTED && npm run dev; exec zsh"
YARN_DEV="cd $SELECTED && yarn run dev"
BUN_HOT="cd $(dirname "$SELECTED") && "$HOME/.bun/bin/bun" --hot $(basename "$SELECTED"); exec zsh"

# This detects what package manager to use and how to use it based on selected path
detect() {
  [[ -f "$1/bun.lock" ]] || [[ -f "$1/bun.lockb" ]] && echo "$BUN_DEV" && return
  [[ -f "$1/pnpm-lock.yaml" ]] && echo "$PNPM_DEV" && return
  [[ -f "$1/package-lock.json" ]] && echo "$NPM_DEV" && return
  [[ -f "$1/yarn.lock" ]] && echo "$YARN_DEV" && return
  [[ "$1" == *.html ]] && echo "$BUN_HOT"
  echo 0
}

# Launch a browser
xdotool key super+4

# detect the specific command for a specific package manager
COMMAND=$(detect "$SELECTED")

# if the command is not 0, open qterminal and run commands inside it with -c flag
# upon receiving ctrl c, start a new session instead of exiting or freezing the old one
[[ "$COMMAND" != 0 ]] && qterminal -e bash -l -c "trap '' INT; $COMMAND" &
sleep 1

# Open the file/dir in neovim
[[ -f "$SELECTED" ]] && kitty -e nvim "$SELECTED" &
[[ -d "$SELECTED" ]] && kitty --directory="$SELECTED" nvim &
