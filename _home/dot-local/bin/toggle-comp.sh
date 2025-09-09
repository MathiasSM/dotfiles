#!/bin/bash

if pgrep xcompmgr &>/dev/null; then
    echo "Turning xcompmgr OFF"
    pkill xcompmgr &
else
    echo "Turning xcompmgr ON"
    xcompmgr -cC -fF -D4 -I0.05 &
fi

exit 0
