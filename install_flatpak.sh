#!/usr/bin/env bash

set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

source "$DOTFILES/utils.sh"

# ==============================================================================

FLATPAK_APPS=(
    "com.obsproject.Studio"         # OBS
    "com.spotify.Client"            # Spotify
    "com.valvesoftware.Steam"       # Steam
    "org.gimp.GIMP"                 # Gimp
    "org.godotengine.Godot"         # Godot
    "org.kde.krita"                 # Krita
    "org.libreoffice.LibreOffice"   # LibreOffice
    "org.libretro.RetroArch"        # RetroArch
    "org.mozilla.Thunderbird"       # Thunderbird
    "org.mozilla.firefox"           # Firefox
    "org.telegram.desktop"          # Telegram
)

# ------------------------------------------------------------------------------

FLATHUB_URL="https://dl.flathub.org/repo/flathub.flatpakrepo"

parse_common_args

echo "Installing flatpak packages..."
dry_run flatpak remote-add --if-not-exists flathub "$FLATHUB_URL"
if [ "$FORCE_INSTALL" == true ]; then
    debug "WARN: Forcing reinstall of flatpak packages"
    FLATPAK_FLAGS="$FLATPAK_FLAGS --reinstall"
fi
dry_run flatpak install $FLATPAK_FLAGS flathub "${FLATPAK_APPS[@]}"
echo "DONE!"
