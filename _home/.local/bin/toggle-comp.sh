#!/bin/bash

args=(
    "--urgency=low"
    "--app-name=Compositor"
    "--icon=window"
)
if pgrep picom &>/dev/null; then
    pkill picom &
    notify-send ${args[@]} "Compositor" "OFF"
else
    picom &
    notify-send ${args[@]} "Compositor" "ON"
fi

exit 0
