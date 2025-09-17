#!/usr/bin/env bash

set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

source "$DOTFILES/utils.sh"

# ==============================================================================

# install_<app> is defined later in this file
OPT_APPS=(
    "nvim"
    "ghcup"
)

# ------------------------------------------------------------------------------

ARCH="$(uname -m)"  # To pick the right packages

verify_installed() {
    if [ -s "/opt/$1" ]; then
        echo "[WARN] /opt/$1 already linked, remove it to force reinstall."
    elif [ -d "/opt/$1" ]; then
        echo "[WARN] /opt/$1 directory present, skipping install."
    else
        "install_$1"
    fi
}

# ------------------------------------------------------------------------------
# Nvim - https://github.com/neovim/neovim/releases

GITHUB="https://github.com"
NVIM_URL_FORMAT="$GITHUB/neovim/neovim/releases/download/%s/%s.tar.gz"
NVIM_REL_VERSION="stable"

install_nvim() {
    case $OS in
        macos) release_name="nvim-macos-$ARCH" ;;
        linux) release_name="nvim-linux-$ARCH" ;;
        *) echo "[ERROR] Unsupported OS: $OS, skipping nvim"; return 10 ;;
    esac
    local tmpdir=$(mktemp -p "$TMPDIR" -d "$MKTEMP_TEMPLATE")
    printf -v url "$NVIM_URL_FORMAT" "$NVIM_REL_VERSION" "$release_name"
    dry_run curl "$CURL_FLAGS" "$url" -o "$tmpdir/nvim.tar.gz"
    if [[ "$OS" == "macos" ]]; then 
        # Clear attributes related to "unknown developer" warnings
        debug "macos only:"
        dry_run xattr -c "$tmpdir/nvim.tar.gz"
    fi
    dry_run sudo rm -rf "/opt/nvim" "/opt/$release_name"
    dry_run sudo tar -C "/opt" -xzf "$tmpdir/nvim.tar.gz"
    dry_run sudo mv "/opt/$release_name" "/opt/nvim"
}

# ------------------------------------------------------------------------------
# GHCUp

GHCUP_URL="https://downloads.haskell.org/~ghcup/$ARCH-linux-ghcup"

install_ghcup() {
    local tmpdir=$(mktemp -p "$TMPDIR" -d "$MKTEMP_TEMPLATE")
    dry_run curl "$CURL_FLAGS" "$GHCUP_URL" -o "$tmpdir/ghcup"
    dry_run sudo chmod +x "$tmpdir/ghcup"
    local ghcup_dir="/opt/ghcup"
    dry_run sudo rm -rf "$ghcup_dir"
    dry_run sudo mkdir -p "$ghcup_dir/bin"
    dry_run sudo mv "$tmpdir/ghcup" "$ghcup_dir/bin"
}

# ------------------------------------------------------------------------------

parse_common_args

num_apps="${#OPT_APPS[@]}"
echo "Installing $num_apps apps into /opt..."

i=1
for app in "${OPT_APPS[@]}"; do
    printf -v log_group_for "[%2d/%2d] %s" $i $num_apps $app
    start_log_group "$log_group_for"
    verify_installed "$app"
    end_log_group
    (( i++ ))
done

echo "DONE!"
