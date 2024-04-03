#!/usr/bin/env bash


set -e
set -u

DOTFILES=$HOME/.dotfiles
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}

usage() {
    echo "Usage: $0 [OPTIONS] [TARGET]"
    echo "Options:"
    echo "  -h, --help      Display this help message and exit"
    echo "  -v, --version   Display version information and exit"
    echo "  -n, --dry-run   Dry run. Do not link or install anything"
    echo "  -D, --delete    Pass-through to stow (delete links)"
    echo "  -R, --restow    Pass-through to stow (recreate links)"
    echo "Targets (choose one):"
    echo "  macos           Install dotfiles for macOS and exit"
    echo "  debian          Install dotfiles for Debian-like and exit"
    echo "  redhat          Install dotfiles for RHEL-like and exit"
}

version() {
    echo "1.0"
}

DEBUG=${DEBUG:-false}
DRY_RUN=false

install_homebrew() {
    $DEBUG && echo "[DEBUG] Installing homebrew"
    echo "[...] Checking if homebrew is installed"
    if ! command -v "brew" &> /dev/null; then
        echo "[...] Homebrew not installed, installing..."
        URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
        $DRY_RUN || /bin/bash -c "$(curl -fsSL $URL)"
    else
        echo "[...] Homebrew already installed!"
    fi
}

build_brewfile(){
    $DEBUG && echo "[DEBUG] Building final brewfile from parts"
    $DRY_RUN || cat $DOTFILES/macos/*.Brewfile > "$DOTFILES/macos/Brewfile"
}

install_brewfile(){
    $DEBUG && echo "[DEBUG] Installing bundle from brewfile"
    $DRY_RUN || brew bundle install --file "$DOTFILES/macos/Brewfile"
}

link_common() {
    $DEBUG && echo "[DEBUG] Checking if stow command is available"
    $DRY_RUN || if ! command -v "stow" &> /dev/null; then
        echo "Command 'stow' is not available. Install and try again?"
        exit 1
    fi

    local INDEX=1
    local TOTAL=11

    link_xdg() {
        echo "$LINKING_ACTION:[$INDEX/$TOTAL] $1"
        $DRY_RUN || stow -d $DOTFILES -t $XDG_CONFIG_HOME $STOW_FLAGS $1
        ((INDEX++))
    }

    link_home(){
        echo "$LINKING_ACTION:[$INDEX/$TOTAL] $1"
        $DRY_RUN || stow -d $DOTFILES -t $HOME $STOW_FLAGS $1
        ((INDEX++))
    }

    $DEBUG && echo "[DEBUG] Running stow for home packages"
    # Keep these sorted!
    link_home "ssh" && post_ssh
    link_home "zsh"

    $DEBUG && echo "[DEBUG] Running stow for xdg-config-home packages"
    # Keeps these sorted!
    link_xdg "amethyst" # Only relevant for macOS
    link_xdg "ghc"
    link_xdg "ghcup"
    link_xdg "git"
    link_xdg "gnupg"
    link_xdg "karabiner" && post_karabiner # Only relevant for macOS
    link_xdg "pgcli"
    link_xdg "psql"
    link_xdg "tmux"

    # TODO: terminfos
    # TODO: linux
}

post_karabiner(){
    [[ $LINKING_ACTION == "Delinking" ]] && return
    $DEBUG && echo "[DEBUG] Checking if karabiner folder (not file) was linked"
    local KARABINER="$XDG_CONFIG_HOME/karabiner"
    [ -L $KARABINER ] && return
    echo "[...] Karabiner needs to symlink the folder, moving original folder"
    $DRY_RUN || mv $KARABINER "$KARABINER.bck"
    echo "[...] Linking karabiner again"
    $DRY_RUN || stow -d $DOTFILES -t $XDG_CONFIG_HOME $STOW_FLAGS "karabiner"
    $DEBUG && echo "[DEBUG] Checking (again) if karabiner folder (not file) was linked"
    [ -L $KARABINER ] && return
    echo "[...] ERROR: Failed to link karabiner folder"
}

post_ssh(){
    [[ $LINKING_ACTION == "Delinking" ]] && return
    echo "[...] Appending ssh_config include to actual file"
    local ssh_cmd="Include '$HOME/.ssh/config.personal'"
    local config="$HOME/.ssh/config"
    $DRY_RUN || touch "$config"
    $DRY_RUN || grep -qF "$ssh_cmd" "$config" || echo "$ssh_cmd" >> "$config"
}

line(){
    local terminal_width=$(tput cols)
    printf '%*s\n' "$terminal_width" '' | tr ' ' '-'
}

remember(){
    echo "[...] Remember to install the following separatedly:"
    echo "[...] - NeoVim: https://github.com/MathiasSM/init.lua"
}

macos() {
    $DEBUG && echo "[DEBUG] Entered macos main"
    if [[ "$(uname -s)" != "Darwin" ]]; then
        read -p "Not macOS. Continue? [y/N]:" answer
        [[ "$answer" != "y" && "$answer" != "Y" ]] && exit 1
    fi

    local TOTAL=4
    echo "[macOS]:Installing!" && line
    echo "[macOS]:[1/$TOTAL] install_homebrew ..."
    $SKIP_HOMEBREW && echo "Skipping homebrew!" || install_homebrew
    echo "[macOS]:[2/$TOTAL] build_brewfile ..."
    $SKIP_HOMEBREW && echo "Skipping homebrew!" || build_brewfile
    echo "[macOS]:[3/$TOTAL] install_brewfile ..."
    $SKIP_HOMEBREW && echo "Skipping homebrew!" || install_brewfile
    echo "[macOS]:[4/$TOTAL] link_common ..."
    link_common
    remember
    line && echo "macOS:All done!"
}

debian() {
    $DEBUG && echo "[DEBUG] Entered debian main"
    if [[ "$(uname -s)" != "Linux" ]] || ! command -v apt &> /dev/null; then
        read -p "Not Debian, or 'apt' not present. Continue? [y/N]:" answer
        [[ "$answer" != "y" && "$answer" != "Y" ]] && exit 1
    fi

    local TOTAL=1
    echo "[Debian]:Installing!" && line
    echo "[Debian]: Debian is not setup, skipping dependencies installation"
    echo "[Debian]:[1/$TOTAL] link_common ..."
    link_common
    line && echo "[Debian]:All done!"
}

redhat() {
    $DEBUG && echo "[DEBUG] Entered redhat main"
    if [[ "$(uname -s)" != "Linux" ]] || ! command -v yum &> /dev/null ; then
        read -p "Not Linux or 'yum' not present. Continue? [y/N]:" answer
        [[ "$answer" != "y" && "$answer" != "Y" ]] && exit 1
    fi

    local TOTAL=1
    echo "[RHEL]:Installing!" && line
    echo "[RHEL]: RHEL is not setup, skipping dependencies installation"
    echo "[RHEL]:[1/$TOTAL] link_common ..."
    link_common
    line && echo "[RHEL]:All done!"
}

setup_dry_run(){
    DRY_RUN=true
    echo "Dry run active. Will print, but not execute destructive commands."
}


# ==============================================================================


TARGET=
STOW_FLAGS=
SKIP_HOMEBREW=false
LINKING_ACTION="Linking"

$DEBUG && echo "[DEBUG] Parsing arguments"
for arg in "$@"; do
    $DEBUG && echo "[DEBUG] Parsing '$arg'"
    case $arg in
        -h|--help) usage; exit 0 ;;
        -v|--version) version; exit 0 ;;
        -n|--dry-run) setup_dry_run ;;
        -S|--stow)
            STOW_FLAGS="-S $STOW_FLAGS"
            SKIP_HOMEBREW=true
            LINKING_ACTION="Linking" ;;
        -R|--restow)
            STOW_FLAGS="-R $STOW_FLAGS"
            SKIP_HOMEBREW=true
            LINKING_ACTION="Relinking" ;;
        -D|--delete) 
            STOW_FLAGS="-D $STOW_FLAGS"
            SKIP_HOMEBREW=true
            LINKING_ACTION="Delinking" ;;
        macos) TARGET=macos;;
        debian) TARGET=debian;;
        redhat) TARGET=redhat;;
        *) echo "Unknown option: $arg"; usage; exit 1 ;;
    esac
done

$DEBUG && echo "[DEBUG] Running target"
case $TARGET in
    macos) macos;;
    debian) debian;;
    redhat) redhat;;
    *) echo "ERROR: No target specified."; usage; exit 1;;
esac
