#!/bin/sh

. ~/.profile

export XDG_CURRENT_DESKTOP=xmonad

# Root X Window
xsetroot -cursor_name left_ptr	# Set cursor to the usual pointer

# Set keymaps
setxkbmap -option caps:ctrl_modifier # Make caps_lock be an extra ctrl key
setxkbmap -option compose:menu       # Use menu key as compose key

# X settings
xset b off           # Shut up bell
autorepeat_rate=50   # Repeats per second
autorepeat_delay=300 # Milliseconds before autorepeat
xset r on            # Enable autorepeat on keys
xset r rate $autorepeat_delay $autorepeat_rate

# Locking session
XSECURELOCK_PASSWORD_PROMPT=time \
XSECURELOCK_SAVER=saver_xscreensaver \
xss-lock -n /usr/libexec/xsecurelock/dimmer -l -- xsecurelock &

# Management
xfce4-power-manager & # Power
dunst &               # Notifications

# Wallpaper setter
variety &

# Applets (fallback from clickable stuff in xmobar)
stalonetray \
    --sticky \
    --window-strut none --window-layer bottom \
    --vertical --geometry 1x1-20-70 \
    --icon-gravity SE --grow-gravity SE \
    --icon-size 32 &
nm-applet --sm-disable & # - Network Manager
blueman-applet &         # - Bluetooth

exec xmonad

