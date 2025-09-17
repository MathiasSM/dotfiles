#!/usr/bin/env bash

set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

source "$DOTFILES/utils.sh"

# ==============================================================================

parse_common_args

source="$DOTFILES"
target="$HOME"
app="_home"

echo "Linking (stowing) $app!"

stow_flags="-vv"
for arg in ${ARGS[@]}; do
    case $arg in
        -S|--stow) stow_flags="-S $stow_flags" ;;
        -R|--restow) stow_flags="-R $stow_flags" ;;
        -D|--delete) 
            stow_flags="-D $stow_flags" 
            is_delinking=true
            ;;
    esac
done


dry_run stow -d "$source" -t "$target" $stow_flags "$app"

