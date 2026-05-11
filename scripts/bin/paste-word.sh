#!/usr/bin/env bash
printf 'unnecessary' | xsel --clipboard --input
sleep 0.1
xdotool key --clearmodifiers ctrl+v
xdotool keyup super
