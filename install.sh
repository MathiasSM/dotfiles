#!/usr/bin/env bash

set -e
set -u

# ==============================================================================
# Per-user configuration (kinda?)
# ==============================================================================
DOTFILES=$HOME/.dotfiles
LOG_GROUP_SEP="    "

# For the following lists, feel free to comment out any
APPS_FOR_HOME=(
    "ssh"
    "zsh"
    "env"
    "xorg"
)
APPS_FOR_XDG=(
    "alacritty"
    "amethyst"
    "autorandr"
    "ghc"
    "ghcup"
    "git"
    "gnupg"
    "karabiner"
    "pgcli"
    "psql"
    "tmux"
    "variety"
    "xmobar"
    "xmonad"
)



# ==============================================================================
# Documentation / Usage
# ==============================================================================
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



# ==============================================================================
# Constants
# ==============================================================================
LINKING_ACTION_LINKING="Linking"
LINKING_ACTION_RELINKING="Relinking"
LINKING_ACTION_DELINKING="Delinking"



# ==============================================================================
# State
# ==============================================================================
# These will be set once and won't be modified
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
DEBUG=${DEBUG:-false}
DRY_RUN=false
TARGET=
STOW_FLAGS=
SKIP_HOMEBREW=false
LINKING_ACTION=$LINKING_ACTION_LINKING

# These will be changing during the script
LOG_PREFIX=""
LINKING_APPS=()
LINKING_TARGET=



# ==============================================================================
# Utility functions
# ==============================================================================
# Some printing helper
bigline(){
    local terminal_width=$(tput cols)
    printf '%*s\n' "$terminal_width" '' | tr ' ' '='
}
line(){
    local terminal_width=$(tput cols)
    printf '%*s\n' "$terminal_width" '' | tr ' ' '-'
}
# Some tabbed logging
start_log_group(){
    # if [[ -z "${LOG_PREFIX// }" ]]; then
    #     LOG_PREFIX="[$1]"
    # else
    #     LOG_PREFIX="$LOG_PREFIX$LOG_GROUP_SEP[$1]"
    # fi
    echo "$LOG_PREFIX$1"
    LOG_PREFIX="$LOG_PREFIX$LOG_GROUP_SEP"
}
end_log_group(){
    # local pat=$(printf '%q' "[$1]")
    # LOG_PREFIX="${LOG_PREFIX%$pat}" # Careful with special characters!
    # LOG_PREFIX="${LOG_PREFIX%$LOG_GROUP_SEP}"
    LOG_PREFIX="${LOG_PREFIX%$LOG_GROUP_SEP}" 
}
# Change behavior
setup_dry_run(){
    DRY_RUN=true
    echo "Dry run active. Will print, but not execute destructive commands."
}
check_stow(){
    is_debug && echo "[DEBUG] Checking if 'stow' is available"
    if ! command -v "stow" &> /dev/null; then
        echo "[ERROR] Command 'stow' is not available. Install and try again?"
        exit 1
    fi
    echo "$LOG_PREFIX Command 'stow' is available!"
}

# State getters
is_dry_run() {
    [[ "$DRY_RUN" == "true" ]]
}
is_debug() {
    [[ "$DEBUG" == "true" ]]
}
is_delinking() {
    [[ "$LINKING_ACTION" == "$LINKING_ACTION_DELINKING" ]]
}
is_relinking() {
    [[ "$LINKING_ACTION" == "$LINKING_ACTION_RELINKING" ]]
}



# ==============================================================================
# MacOS-only
# ==============================================================================
install_homebrew() {
    is_debug && echo "[DEBUG] Installing homebrew"
    echo "$LINK_PREFIX Checking if homebrew is installed"
    if ! command -v "brew" &> /dev/null; then
        echo "$LINK_PREFIX Homebrew not installed, installing..."
        URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
        is_dry_run || /bin/bash -c "$(curl -fsSL $URL)"
    else
        echo "$LINK_PREFIX Homebrew already installed!"
    fi
}

build_brewfile(){
    is_debug && echo "[DEBUG] Building final brewfile from parts"
    is_dry_run || cat $DOTFILES/macos/*.Brewfile > "$DOTFILES/macos/Brewfile"
}

install_brewfile(){
    is_debug && echo "[DEBUG] Installing bundle from brewfile"
    is_dry_run || brew bundle install --file "$DOTFILES/macos/Brewfile"
}



# ==============================================================================
# Common to all targets
# ==============================================================================
prepare_linking_apps_for(){
    if [[ "$1" == "HOME" ]]; then
	LINKING_APPS=(${APPS_FOR_HOME[@]})
	LINKING_TARGET="$HOME"
	return
    fi 
    if [[ "$1" == "XDG" ]]; then
        LINKING_APPS=(${APPS_FOR_XDG[@]})
	LINKING_TARGET="$XDG_CONFIG_HOME"
	return
    fi 
    echo "[ERROR] Unknown linking target: '$1'"
    exit 1
}

link_apps_for(){
    is_debug && echo "[DEBUG] Calling 'link_apps_for' for $1"
    prepare_linking_apps_for $1

    local num_apps="${#LINKING_APPS[@]}"
    is_debug && echo "[DEBUG] There are $num_apps $1 apps configured"

    local i=1
    for app in ${LINKING_APPS[@]}; do
	printf -v log_group_for "[%2d/%2d] %s" $i $num_apps $app
	start_log_group "$log_group_for"
	link_app "$app"
	end_log_group
	((i++))
    done
}

link_app() {
    local app=$1
    local pre_link="pre_$app"
    local post_link="post_$app"
    if $( declare -f "$pre_link" > /dev/null ); then
    	is_debug && echo "[DEBUG] Found pre_link hook for $app"
       "$pre_link" "$app"
    fi
    is_debug && echo "[DEBUG] Running stow for $app"
    is_dry_run || stow -d $DOTFILES -t $LINKING_TARGET $STOW_FLAGS $app
    if $( declare -f "$post_link" > /dev/null ); then
    	is_debug && echo "[DEBUG] Found post_link hook for $app"
       "$post_link" "$app"
    fi
}

link_common() {
    local log_group="Prepare..."
    start_log_group "$log_group"
    check_stow
    end_log_group

    local log_group="Apps:HOME"
    start_log_group "$log_group"
    is_debug && echo "[DEBUG] Running stow for home packages"
    link_apps_for "HOME"
    end_log_group

    local log_group="Apps:XDG"
    start_log_group "$log_group"
    is_debug && echo "[DEBUG] Running stow for xdg-config-home packages"
    link_apps_for "XDG"
    end_log_group
}



# ==============================================================================
# Hooks {post_,pre_}$app
# ==============================================================================
post_variety(){
    [[ $LINKING_ACTION == "Delinking" ]] && return
    echo "$LOG_PREFIX Variety works best given a wallhaven.cc API key (do not commit that!)"
}

post_karabiner(){
    is_delinking && return
    is_debug && echo "[DEBUG] Checking if karabiner folder (not file) was linked"
    local KARABINER="$XDG_CONFIG_HOME/karabiner"
    [ -L $KARABINER ] && return
    echo "$LOG_PREFIX Karabiner needs to symlink the folder, moving original folder"
    is_dry_run || mv $KARABINER "$KARABINER.bck"
    echo "$LOG_PREFIX Linking karabiner again"
    is_dry_run || stow -d $DOTFILES -t $XDG_CONFIG_HOME $STOW_FLAGS "karabiner"
    is_debug && echo "[DEBUG] Checking (again) if karabiner folder (not file) was linked"
    [ -L $KARABINER ] && return
    echo "$LOG_PREFIX [ERROR]: Failed to link karabiner folder"
}

post_ssh(){
    is_delinking && return
    echo "$LOG_PREFIX Appending ssh_config include to actual file"
    local ssh_cmd="Include '$HOME/.ssh/config.personal'"
    local config="$HOME/.ssh/config"
    is_dry_run || touch "$config"
    is_dry_run || grep -qF "$ssh_cmd" "$config" || echo "$ssh_cmd" >> "$config"
}

remember(){
    echo ""
    echo "NOTES:"
    echo "Remember to install the following separatedly:"
    echo " - NeoVim: https://github.com/MathiasSM/init.lua"
    echo ""
}



# ==============================================================================
# Main entry points
# ==============================================================================

macos() {
    if [[ "$(uname -s)" != "Darwin" ]]; then
        read -p "[PROMPT] Not macOS. Continue? [y/N]:" answer
        [[ "$answer" != "y" && "$answer" != "Y" ]] && exit 1
    fi

    start_log_group "Installing..."
    echo "$LOG_PREFIX install_homebrew ..."
    $SKIP_HOMEBREW && echo "$LOG_PREFIX Skipping homebrew!" || install_homebrew

    echo "$LOG_PREFIX build_brewfile ..."
    $SKIP_HOMEBREW && echo "Skipping homebrew!" || build_brewfile

    echo "$LOG_PREFIX install_brewfile ..."
    $SKIP_HOMEBREW && echo "Skipping homebrew!" || install_brewfile
    echo `line`
    end_log_group

    start_log_group "$LINKING_ACTION..."
    link_common
    echo `line`
    end_log_group
}

debian() {
    if [[ "$(uname -s)" != "Linux" ]] || ! command -v apt &> /dev/null; then
        read -p "[PROMPT] Not Debian, or 'apt' not present. Continue? [y/N]:" answer
        [[ "$answer" != "y" && "$answer" != "Y" ]] && exit 1
    fi

    start_log_group "Installing..."
    echo "$LOG_PREFIX Oops! Debian is not setup, skipping dependencies installation"
    end_log_group
    echo `line`

    start_log_group "$LINKING_ACTION..."
    link_common
    end_log_group
    echo `line`
}

redhat() {
    if [[ "$(uname -s)" != "Linux" ]] || ! command -v yum &> /dev/null ; then
        read -p "[PROMT] Not Linux, or 'yum' not present. Continue? [y/N]:" answer
        [[ "$answer" != "y" && "$answer" != "Y" ]] && exit 1
    fi

    start_log_group "Installing..."
    echo "$LOG_PREFIX RHEL is not setup, skipping dependencies installation"
    end_log_group
    echo `line`

    start_log_group "$LINKING_ACTION..."
    link_common
    end_log_group
    echo `line`
}


# ==============================================================================
# Main script
# ==============================================================================

is_debug && echo "[DEBUG] Parsing arguments"
for arg in "$@"; do
    is_debug && echo "[DEBUG] Parsing '$arg'"
    case $arg in
        -h|--help) usage; exit 0 ;;
        -v|--version) version; exit 0 ;;
        -n|--dry-run) setup_dry_run ;;
        -S|--stow)
            STOW_FLAGS="-S $STOW_FLAGS"
            SKIP_HOMEBREW=true
            LINKING_ACTION="$LINKING_ACTION_LINKING" ;;
        -R|--restow)
            STOW_FLAGS="-R $STOW_FLAGS"
            SKIP_HOMEBREW=true
            LINKING_ACTION="$LINKING_ACTION_RELINKING" ;;
        -D|--delete) 
            STOW_FLAGS="-D $STOW_FLAGS"
            SKIP_HOMEBREW=true
            LINKING_ACTION="$LINKING_ACTION_DELINKING" ;;
        macos) TARGET=macos;;
        debian) TARGET=debian;;
        redhat) TARGET=redhat;;
        *) echo "[ERROR] Unknown option: $arg"; usage; exit 1 ;;
    esac
done

is_debug && echo "[DEBUG] Running target $TARGET"
echo `bigline`
echo "Starting $TARGET!"
echo `bigline`
case $TARGET in
    macos) macos;;
    debian) debian;;
    redhat) redhat;;
    *) echo "[ERROR] No target specified."; usage; exit 1;;
esac
echo "All done with $TARGET!"
echo `bigline`
remember

# ------------------------------------------------------------------------------
# ==============================================================================
