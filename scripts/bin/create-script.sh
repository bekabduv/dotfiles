#!/usr/bin/env bash

FILENAME=$(kdialog --inputbox 'Enter a file name to create and open in nvim:')

kitty --directory="$HOME/dotfiles/scripts/bin" nvim "$FILENAME"
