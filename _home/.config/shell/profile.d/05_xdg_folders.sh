#!/usr/bin/env bash

XDG_FOLDERS=(
    "$XDG_CONFIG_HOME"
    "$XDG_DATA_HOME"
    "$XDG_STATE_HOME"
    "$XDG_CACHE_HOME"
    "$XDG_BIN_HOME"
)
for i in "${XDG_FOLDERS[@]}"; do
    [ ! -d "$i" ] || mkdir -p "$i"
done
unset XDG_FOLDERS


