#!/usr/bin/env bash

set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes



# ==============================================================================
# Per-user configuration (kinda?)
# ==============================================================================
TMPDIR="${TMPDIR:-/tmp}"
DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
ZDOTDIR=${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}

# Log Formatting
LOG_GROUP_SEP="    "

# For the following lists, feel free to comment out any
APPS_FOR_HOME=(
    "ssh"
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
    "zsh"
)

# https://github.com/neovim/neovim/releases
NVIM_RELEASE_VERSION="stable"


# TODO: Move to external file, similar to Brewfile
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

# NOTE: These need a install_opt_<app> to be defined!
OPT_APPS=(
    "neovim"
    "pyenv"
    "nodenv"
    "ghcup"
)


# ==============================================================================
# Constants
# ==============================================================================
LINKING_ACTION_LINKING="Linking"
LINKING_ACTION_RELINKING="Relinking"
LINKING_ACTION_DELINKING="Delinking"

HOMEBREW_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"

FLATHUB_URL="https://dl.flathub.org/repo/flathub.flatpakrepo"

GITHUB="https://github.com"
PYENV_URL="$GITHUB/pyenv/pyenv.git"
PYENV_CCACHE_URL="$GITHUB/pyenv/pyenv-ccache.git"
PYENV_VIRTUALENV_URL="$GITHUB/pyenv/pyenv-virtualenv.git"

NODENV_URL="$GITHUB/nodenv/nodenv.git"
NODENV_BUILD_URL="$GITHUB/nodenv/node-build.git"
NODENV_UPDATE_URL="$GITHUB/nodenv/nodenv-update.git"
NODENV_DEFAULT_PACKAGES_URL="$GITHUB/nodenv/nodenv-default-packages.git"

NEOVIM_URL_FORMAT="$GITHUB/neovim/neovim/releases/download/%s/%s.tar.gz"

MKTEMP_TEMPLATE_PREFIX="dotfiles-install"
MKTEMP_TEMPLATE="$MKTEMP_TEMPLATE_PREFIX.XXXX"

CURL_FLAGS_VERBOSE="-Lf"
CURL_FLAGS_SILENT="-LSsf" # It does show errors

GIT_FLAGS_VERBOSE=""
GIT_FLAGS_SILENT="--quiet"

APT_FLAGS_VERBOSE="-q"
APT_FLAGS_SILENT="-qq"

FLATPAK_INSTALL_FLAGS_VERBOSE="--assumeyes"
FLATPAK_INSTALL_FLAGS_SILENT="--assumeyes --noninteractive"



# ==============================================================================
# State
# ==============================================================================
# These will be set once and won't be modified
ARCH="$(uname -m)"  # To pick the right packages
ARGS="$@"           # To use them within functions
CURL_FLAGS="$CURL_FLAGS_SILENT"
GIT_FLAGS="$GIT_FLAGS_SILENT"
APT_FLAGS="$APT_FLAGS_SILENT"
FLATPAK_INSTALL_FLAGS="$FLATPAK_INSTALL_FLAGS_SILENT"

# Modes / behavior
DEBUG=${DEBUG:-false}
DRY_RUN=${DRY_RUN:-false}
FORCE_REINSTALL=false
SKIP_INSTALL=true
TARGET=
LINKING_ACTION=$LINKING_ACTION_LINKING
STOW_FLAGS=

LOG_PREFIX=""

# https://github.com/neovim/neovim/releases
NVIM_RELEASE_NAME=

# TODO: macos version?
GHCUP_URL="https://downloads.haskell.org/~ghcup/$ARCH-linux-ghcup"
# TODO: goup, rustup


# State getters
has_no_target() {
    [[ "$TARGET" == "" ]]
}
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
is_macos() {
    [[ "$TARGET" == "macos" ]]
}
is_install() {
    [[ "$SKIP_INSTALL" != "true" ]]
}
is_force_reinstall() {
    [[ "$FORCE_REINSTALL" == "true" ]]
}


# ==============================================================================
# Utility functions
# ==============================================================================
bigline(){
    local terminal_width=$(tput cols)
    printf '%*s\n' "$terminal_width" '' | tr ' ' '='
}
line(){
    local terminal_width=$(tput cols)
    printf '%*s\n' "$terminal_width" '' | tr ' ' '-'
}
start_log_group(){
    echo "$LOG_PREFIX$1"
    LOG_PREFIX="$LOG_PREFIX$LOG_GROUP_SEP"
}
end_log_group(){
    LOG_PREFIX="${LOG_PREFIX%$LOG_GROUP_SEP}" 
}
debug() {
    GR='\e[0;30m'
    NC='\e[0m' # No Color
    is_debug && echo -e "${GR}[DEBUG] $1${NC}" || true
}



# ==============================================================================
# Modes: Usage/docs, dry run, debug...
# ==============================================================================
usage() {
    echo "Usage: ./install.sh [OPTION]... [TARGET]"
    echo "Options:"
    echo "  -h, --help      Display this help message and exit"
    echo "  -v, --version   Display version information and exit"
    echo "  -n, --dry-run   Dry run. Do not link or install anything"
    echo "  -S, --stow      Pass-through to stow. Default links with no install"
    echo "  -D, --delete    Pass-through to stow (delete links)"
    echo "  -R, --restow    Pass-through to stow (recreate links)"
    echo "Targets (choose one):"
    echo "  macos           Install dotfiles for macOS and exit"
    echo "  debian          Install dotfiles for Debian-like and exit"
    echo "  redhat          Install dotfiles for RHEL-like and exit"
}

# Modes
version() {
    echo "1.1" # Probably only makes sense to me
}
set_force_reinstall() {
    FORCE_REINSTALL=true
    echo "Forcing reinstall of all software"
}
set_dry_run() {
    DRY_RUN=true
    echo "Dry run active. Will print, but not execute destructive commands."
}
set_debug() {
    CURL_FLAGS="$CURL_FLAGS_VERBOSE"
    GIT_FLAGS="$GIT_FLAGS_VERBOSE"
    APT_FLAGS="$APT_FLAGS_VERBOSE"
    FLATPAK_INSTALL_FLAGS="$FLATPAK_INSTALL_FLAGS_VERBOSE"
    echo "Debug logging active. Some commands used will also be noisier."
}

# Traps
clean_temp() {
    debug "clean_temp"
    local result="$?"
    echo "Received $1 signal. Cleaning up before exit..."
    local to_remove="$TMPDIR/$MKTEMP_TEMPLATE_PREFIX*"
    echo "- Removing lefover files ($to_remove)..."
    rm -rf "$to_remove"
    echo "Done!"
    exit $result
}
trap clean_temp SIGHUP SIGQUIT SIGABRT SIGTERM



# ==============================================================================
# [macos] Install (homebrew)
# ==============================================================================
install_homebrew() {
    debug "install_homebrew"
    echo "$LINK_PREFIX Checking if homebrew is installed"
    if command -v "brew" &> /dev/null && ! is_force_reinstall; then
        echo "$LINK_PREFIX Homebrew already installed!"
        return
    fi
    if is_force_reinstall; then
        echo "$LINK_PREFIX Forced reinstall..."
    else
        echo "$LINK_PREFIX Homebrew not installed, installing..."
    fi
    is_dry_run || curl "$CURL_FLAGS" "$HOMEBREW_URL" | bash

}

build_brewfile(){
    debug "build_brewfile"
    is_dry_run || cat "$DOTFILES/macos/*.Brewfile" > "$DOTFILES/macos/Brewfile"
}

install_brewfile(){
    debug "install_brewfile"
    is_dry_run || brew bundle install --file "$DOTFILES/macos/Brewfile"
}



# ==============================================================================
# [linux] Install from package managers
# ==============================================================================

install_apt() {
    debug "install_apt"
    echo "$LOG_PREFIX [WARNING] Not implemented. Skipping."
}

install_yum() {
    debug "install_yum"
    echo "$LOG_PREFIX [WARNING] Not implemented. Skipping."
}

# TODO: Use external file instead of this list
install_flatpak() {
    debug "install_flatpak"
    debug "- Installing flatpak (APT_FLAGS=$APT_FLAGS)"
    is_dry_run || sudo apt-get $APT_FLAGS install flatpak
    debug "- Installing flathub repository ($FLATHUB_URL)"
    is_dry_run || flatpak remote-add --if-not-exists flathub "$FLATHUB_URL"
    debug "- Installing packages (FLAGS=$FLATPAK_INSTALL_FLAGS)"
    if is_force_reinstall; then
        echo "Forcing reinstall..."
        FLATPAK_INSTALL_FLAGS="$FLATPAK_INSTALL_FLAGS --reinstall"
    fi
    is_dry_run || flatpak install $FLATPAK_INSTALL_FLAGS flathub "${FLATPAK_APPS[@]}"
}



# ==============================================================================
# [common] Install into /opt
# ==============================================================================
install_opt() {
    debug "install_opt"
    local num_apps="${#OPT_APPS[@]}"
    debug "- There are $num_apps apps configured..."
    local i=1
    for app in "${OPT_APPS[@]}"; do
        printf -v log_group_for "[%2d/%2d] %s" $i $num_apps $app
        start_log_group "$log_group_for"
        "install_opt_$app"
        end_log_group
        (( i++ ))
    done
}

install_opt_neovim() {
    debug "install_neovim"
    if is_force_reinstall; then
        echo "$LOG_PREFIX Forcing reinstall of neovim"
    elif [ -d "/opt/$NVIM_RELEASE_NAME" ]; then
        echo "$LOG_PREFIX [WARNING] nvim already present, skipping."
        return
    fi
    local tmpdir=$(mktemp -p "$TMPDIR" -d "$MKTEMP_TEMPLATE")
    debug "- Created tmp dir $tmpdir"
    local url=
    printf -v url "$NEOVIM_URL_FORMAT" "$NVIM_RELEASE_VERSION" "$NVIM_RELEASE_NAME"
    debug "- Downloading neovim from $url"
    is_dry_run || curl "$CURL_FLAGS" "$url" -o "$tmpdir/nvim.tar.gz"
    if is_macos; then 
        # Clear attributes related to "unknown developer" warnings
        debug "- Running xattr -c"
        is_dry_run || xattr -c "$tmpdir/nvim.tar.gz"
    fi
    debug "- Removing any old nvim from /opt"
    is_dry_run || sudo rm -rf "/opt/nvim" "/opt/$NVIM_RELEASE_NAME"
    is_dry_run || sudo rm -rf "/opt/nvim" "/opt/nvim"
    debug "- Extracting to /opt"
    is_dry_run || sudo tar -C "/opt" -xzf "$tmpdir/nvim.tar.gz"
    is_dry_run || sudo ln -s "/opt/$NVIM_RELEASE_NAME" "/opt/nvim"
}

install_opt_pyenv() {
    debug "install_pyenv"
    if is_force_reinstall; then
        echo "$LOG_PREFIX Forcing reinstall of pyenv"
    elif [ -d "/opt/pyenv" ]; then
        echo "$LOG_PREFIX [WARNING] pyenv already present, skipping."
        return
    fi
    local tmpdir=$(mktemp -p "$TMPDIR" -d "$MKTEMP_TEMPLATE")
    debug "- Cloning into $tmpdir"
    is_dry_run || git clone "$GIT_FLAGS" "$PYENV_URL" "$tmpdir"
    debug "- Moving into /opt"
    is_dry_run || sudo rm -rf "/opt/pyenv"
    is_dry_run || sudo mv "$tmpdir" "/opt/pyenv"
    debug "- Running pyenv init"
    is_dry_run || eval "$(/opt/pyenv/bin/pyenv init -)"
    local plugins="$(pyenv root)/plugins"
    install_opt_toolenv_plugin "$plugins" "pyenv-ccache" "$PYENV_CCACHE_URL"
    install_opt_toolenv_plugin "$plugins" "pyenv-virtualenv" "$PYENV_VIRTUALENV_URL"
}

install_opt_nodenv() {
    debug "install_nodenv"
    if is_force_reinstall; then
        echo "$LOG_PREFIX Forcing reinstall of nodenv"
    elif [ -d "/opt/nodenv" ]; then
        echo "$LOG_PREFIX [WARNING] nodenv already present, skipping."
        return
    fi
    local tmpdir=$(mktemp -p "$TMPDIR" -d "$MKTEMP_TEMPLATE")
    debug "- Cloning into $tmpdir"
    is_dry_run || git clone "$GIT_FLAGS" "$NODENV_URL" "$tmpdir"
    debug "- Moving into /opt"
    is_dry_run || sudo rm -rf "/opt/nodenv"
    is_dry_run || sudo mv "$tmpdir" "/opt/nodenv"
    debug "- Running nodenv init"
    is_dry_run || eval "$(/opt/nodenv/bin/nodenv init -)"
    local plugins="$(nodenv root)/plugins"
    install_opt_toolenv_plugin "$plugins" "node-build" "$NODENV_BUILD_URL"
    install_opt_toolenv_plugin "$plugins" "nodenv-update" "$NODENV_UPDATE_URL"
    install_opt_toolenv_plugin "$plugins" "nodenv-default-packages" "$NODENV_DEFAULT_PACKAGES_URL"
}

install_opt_toolenv_plugin() {
    local plugins_path="$1"
    local plugin_name="$2"
    local plugin_url="$3"
    debug "- Plugin:$plugin_name"
    if is_force_reinstall; then
        echo "$LOG_PREFIX Forcing reinstall of $plugin_name"
        is_dry_run || rm -rf "$plugins_path/$plugin_name"
    elif [ -d "$plugins_path/$plugin_name" ]; then
        echo "$LOG_PREFIX [WARNING] $plugin_name already present, skipping."
        return
    fi
    is_dry_run || git clone "$GIT_FLAGS" "$plugin_url" "$plugins_path/$plugin_name"
}

install_opt_ghcup() {
    debug "install_ghcup"
    if is_force_reinstall; then
        echo "$LOG_PREFIX Forcing reinstall of ghcup"
    elif [ -d "/opt/ghcup" ]; then
        echo "$LOG_PREFIX [WARNING] ghcup already present, skipping."
        return
    fi
    local tmpdir=$(mktemp -p "$TMPDIR" -d "$MKTEMP_TEMPLATE")
    debug "- Downloading binary into $tmpdir"
    is_dry_run || curl "$CURL_FLAGS" "$GHCUP_URL" -o "$tmpdir/ghcup"
    local ghcup_dir="/opt/ghcup"
    debug "- Emptying $ghcup_dir"
    is_dry_run || sudo rm -rf "$ghcup_dir"
    debug "- (Re)creating $ghcup_dir"
    is_dry_run || sudo mkdir -p "$ghcup_dir/bin"
    debug "- Moving binary into $ghcup_dir/bin"
    is_dry_run || sudo mv "$tmpdir/ghcup" "$ghcup_dir/bin"
}



# ==============================================================================
# [common] Linking (stow)
# ==============================================================================
check_stow(){
    debug "check_stow"
    if ! command -v "stow" &> /dev/null; then
        echo "[ERROR] Command 'stow' is not available. Install and try again?"
        exit 1
    fi
    echo "$LOG_PREFIX Command 'stow' is available!"
}

link_app() {
    debug "link_app $1 $2"
    local app=$1
    local target=$2
    debug "- Running pre hook, stow and post hook for $app"
    run_app_hook "$app" "pre"
    is_dry_run || stow -d "$DOTFILES" -t "$target" $STOW_FLAGS "$app"
    run_app_hook "$app" "post"
}

link_apps_for(){
    debug "link_apps_for $1"
    local apps_list=()
    local target=

    if [[ "$1" == "HOME" ]]; then
        apps_list=(${APPS_FOR_HOME[@]})
        target="$HOME"
    elif [[ "$1" == "XDG" ]]; then
        apps_list=(${APPS_FOR_XDG[@]})
        target="$XDG_CONFIG_HOME"
    else
        echo "[ERROR] Unknown linking target: '$1'"
        exit 1
    fi 
    debug "- Set target to $target"
    debug "- Set app list to $apps_list"

    local num_apps="${#apps_list[@]}"
    debug "- There are $num_apps $1 apps configured..."

    local i=1
    for app in "${apps_list[@]}"; do
        printf -v log_group_for "[%2d/%2d] %s" $i $num_apps $app
        start_log_group "$log_group_for"
        link_app "$app" "$target"
        end_log_group
        ((i++))
    done
}

link_common() {
    debug "link_common"
    start_log_group "Prepare..."
    check_stow
    end_log_group

    start_log_group "Apps:HOME"
    debug "- Running stow for home packages"
    link_apps_for "HOME"
    end_log_group

    start_log_group "Apps:XDG"
    debug "- Running stow for xdg-config-home packages"
    link_apps_for "XDG"
    end_log_group
}



# ==============================================================================
# Hooks {post_,pre_}$app
# ==============================================================================
run_app_hook() {
    debug "run_app_hook $1 $2"
    local app=$1
    local hook_name=$2
    local hook="${hook_name}_$app"
    if $( declare -f "$hook" > /dev/null ); then
        debug "- Found $hook_name hook for $app. Running."
       "$hook" "$app"
    fi
}

post_zsh(){
    debug "post_zsh"
    [[ $LINKING_ACTION == "Delinking" ]] && return
    echo "$LOG_PREFIX Linking ~/.zshenv to ZDOTDIR"
    is_dry_run || ln -s "$ZDOTDIR/.zshenv" "$HOME/.zshenv"
}

post_variety(){
    debug "post_variety"
    [[ $LINKING_ACTION == "Delinking" ]] && return
    echo "$LOG_PREFIX Add wallhaven.cc API key to variety config (do not commit that!)"
}

post_karabiner(){
    debug "post_karabiner"
    is_delinking && return
    local KARABINER="$XDG_CONFIG_HOME/karabiner"
    [ -L $KARABINER ] && return
    echo "$LOG_PREFIX Karabiner needs to symlink the folder, moving original folder"
    is_dry_run || rm -rf "$KARABINER.bck"
    is_dry_run || mv $KARABINER "$KARABINER.bck"
    echo "$LOG_PREFIX Linking karabiner again"
    is_dry_run || stow -d $DOTFILES -t $XDG_CONFIG_HOME $STOW_FLAGS "karabiner"
    debug "Checking (again) if karabiner folder (not file) was linked"
    [ -L $KARABINER ] && return
    echo "$LOG_PREFIX [WARNING] Failed to link karabiner folder"
}

post_ssh(){
    debug "post_ssh"
    is_delinking && return
    echo "$LOG_PREFIX Appending ssh_config include to actual file"
    local ssh_cmd="Include '$HOME/.ssh/config.personal'"
    local config="$HOME/.ssh/config"
    is_dry_run || touch "$config"
    is_dry_run || grep -qF "$ssh_cmd" "$config" || echo "$ssh_cmd" >> "$config"
}



# ==============================================================================
# Targets (entry points)
# ==============================================================================

macos() {
    if [[ "$(uname -s)" != "Darwin" ]]; then
        read -p "[PROMPT] Not macOS. Continue? [y/N]:" answer
        [[ "$answer" != "y" && "$answer" != "Y" ]] && exit 1
        echo `line`
    fi

    if is_install; then
        start_log_group "Installing homebrew..."
        install_homebrew
        end_log_group
        echo `line`

        start_log_group "Installing homebrew packages..."
        build_brewfile
        install_brewfile
        end_log_group
        echo `line`
    fi

    start_log_group "$LINKING_ACTION..."
    link_common
    echo `line`
    end_log_group
}

debian() {
    if [[ "$(uname -s)" != "Linux" ]] || ! command -v apt &> /dev/null; then
        read -p "[PROMPT] Not Debian, or 'apt' not present. Continue? [y/N]:" answer
        [[ "$answer" != "y" && "$answer" != "Y" ]] && exit 1
        echo `line`
    fi

    if is_install; then
        start_log_group "Installing apt packages..."
        install_apt
        end_log_group
        echo `line`

        start_log_group "Installing flatpak packages..."
        install_flatpak
        end_log_group
        echo `line`

        start_log_group "Installing other (/opt) software..."
        install_opt
        end_log_group
        echo `line`
    fi

    start_log_group "$LINKING_ACTION..."
    link_common
    end_log_group
    echo `line`
}

redhat() {
    if [[ "$(uname -s)" != "Linux" ]] || ! command -v yum &> /dev/null ; then
        read -p "[PROMPT] Not Linux, or 'yum' not present. Continue? [y/N]:" answer
        [[ "$answer" != "y" && "$answer" != "Y" ]] && exit 1
        echo `line`
    fi

    if is_install; then
        start_log_group "Installing yum packages..."
        install_yum
        end_log_group
        echo `line`

        start_log_group "Installing other (/opt) software..."
        install_opt
        end_log_group
        echo `line`
    fi

    start_log_group "$LINKING_ACTION..."
    link_common
    end_log_group
    echo `line`
}


# ==============================================================================
# Main script
# ==============================================================================

parse_args() {
    debug "parse_args (ARGS=${ARGS[@]})"
    for arg in ${ARGS[@]}; do
        debug "- Parsing: '$arg'"
        case $arg in
            -h|--help)
                debug "  running usage and exit"
                usage
                exit 0 ;;
            -v|--version)
                debug "  running version and exit"
                version
                exit 0 ;;
            -f|--force)
                debug "  setting force reinstall"
                set_force_reinstall ;;
            -n|--dry-run)
                debug "  setting dry run"
                set_dry_run ;;
            -S|--stow)
                debug "  setting explicit link-only"
                STOW_FLAGS="-S $STOW_FLAGS"
                LINKING_ACTION="$LINKING_ACTION_LINKING" ;;
            -R|--restow)
                debug "  setting explicit relink-only"
                STOW_FLAGS="-R $STOW_FLAGS"
                LINKING_ACTION="$LINKING_ACTION_RELINKING" ;;
            -I|--install)
                debug "  setting explicit relink-only"
                SKIP_INSTALL=false
                LINKING_ACTION="$LINKING_ACTION_RELINKING" ;;
            -D|--delete) 
                debug "  setting explicit delink-only"
                STOW_FLAGS="-D $STOW_FLAGS"
                LINKING_ACTION="$LINKING_ACTION_DELINKING" ;;
            macos)
                debug "  setting target as macos"
                TARGET=macos
                NVIM_RELEASE_NAME="nvim-macos-$ARCH" ;;
            debian)
                debug "  setting target as debian"
                TARGET=debian
                NVIM_RELEASE_NAME="nvim-linux64" ;;
            redhat)
                debug "  setting target as redhat"
                TARGET=redhat
                # TODO: Use nvim version with correct libc
                NVIM_RELEASE_NAME="nvim-linux64" ;;
            *) echo "[ERROR] Unknown option: $arg"; usage; exit 1 ;;
        esac
    done
    if has_no_target; then
        echo "[ERROR] No target specified"; usage; exit 1
    fi
}

run_target() {
    debug "run_target"
    case $TARGET in
        macos) macos;;
        debian) debian;;
        redhat) redhat;;
        *) echo "[ERROR] Unknown target: $TARGET"; usage; exit 1;;
    esac
}

run_main() {
    debug "main"
    parse_args
    echo `bigline`
    echo "Starting $TARGET!"
    echo `bigline`
    run_target
    echo `bigline`
    echo "All done with $TARGET!"
    echo `bigline`
}

is_debug && set_debug

run_main

# ------------------------------------------------------------------------------
# ==============================================================================
