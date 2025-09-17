#!/usr/bin/env bash

set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

source "$DOTFILES/utils.sh"

# ==============================================================================

APT_PACKAGES=(
    "flatpak"
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
