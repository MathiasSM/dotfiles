#!/bin/sh

. ~/.profile

export XDG_CURRENT_DESKTOP=xmonad

# Root X Window
xsetroot -cursor_name left_ptr	# Set cursor to the usual pointer

# Locking session
xscreensaver -no-splash &	# Screensaver on most (relevant) systemd signals
xss-lock --ignore-sleep -- xscreensaver-command -lock & # Manage all systemd signals

# Flare
variety &                # Wallpaper (runs feh on its own)

# Power management
xfce4-power-manager &    # Power Manager

# Other Applets
trayer &                 # Tray bar
nm-applet --sm-disable & # - Network Manager
blueman-applet &         # - Bluetooth

exec xmonad
