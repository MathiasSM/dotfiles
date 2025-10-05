#!/usr/bin/env bash

set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

source "$DOTFILES/utils.sh"

# ==============================================================================

APT_PACKAGES=(
    # Required for life
    "git"
    "git-doc"

    # Required for install_flatpak
    "flatpak"
    "flatpak-xdg-utils"
    # Required for linking
    "stow"

    # My xsession
    "arandr"
    "autorandr"
    "dunst"
    "feh"
    "picom"
    "rofi"
    "scrot"
    "tmux"
    "variety"
    "xfce4-power-manager"
    "xfce4-power-manager-plugins"
    "xsecurelock"
    "xserver-xorg-input-libinput"
    "xss-lock"
    "zsh"
    "zsh-doc"

    # Docs
    "manpages"
    "manpages-dev"
    "manpages-posix"
    "manpages-posix-dev"

    # My basics
    "alacritty"
    "caffeine"
    "mpv"
    "mpv-mpris"

    # Tools
    "bat"
    "ffmpeg"
    "ffmpeg-doc"
    "gpg"
    "graphviz"
    "graphviz-doc"
    "htop"
    "imagemagick"
    "imagemagick-doc"
    "iotop"
    "jq"
    "lynx"
    "make"
    "make-doc"
    "pandoc"
    "pgcli"
    "powertop"

    # Basic fonts
    "fonts-kanjistrokeorders"
    "fonts-mathjax"
    "fonts-noto"
    "fonts-noto-cjk"
    "fonts-open-sans"
    "fonts-opendyslexic"
    "fonts-opensymbol"
)

# ------------------------------------------------------------------------------

parse_common_args

echo "Installing apt packages..."
if [ "$FORCE_INSTALL" == true ]; then
    debug "WARN: Forcing reinstall of apt packages"
    APT_FLAGS="$APT_FLAGS --reinstall"
fi
dry_run sudo apt install $APT_FLAGS "${APT_PACKAGES[@]}"
echo "DONE!"
