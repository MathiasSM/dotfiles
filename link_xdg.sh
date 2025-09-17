#!/usr/bin/env bash

set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

source "$DOTFILES/utils.sh"

# ==============================================================================

run_app_hook() {
    local app=$1
    local hook_name=$2
    local hook="${hook_name}_$app"
    if $( declare -f "$hook" > /dev/null ); then
       "$hook" "$app"
    fi
}

# ------------------------------------------------------------------------------

post_zsh(){
    debug "post_zsh"
    [ "$IS_DELINKING" == "true" ] && return
    echo "$LOG_PREFIX INFO: Please export DOTFILES from zshrc.d"
    echo "$LOG_PREFIX \$ export DOTFILES='$DOTFILES'"
    echo "$LOG_PREFIX INFO: Please link ~/.zshenv to ZDOTDIR:"
    echo "$LOG_PREFIX \$ ln -s $ZDOTDIR/.zshenv ~/.zshenv"
}

post_karabiner(){
    debug "post_karabiner"
    [ "$IS_DELINKING" == "true" ] && return
    local KARABINER="$XDG_CONFIG_HOME/karabiner"
    [ -L $KARABINER ] && return
    echo "$LOG_PREFIX Karabiner needs to symlink the folder directly!"
    echo "$LOG_PREFIX Moving things around to make it happen"
    dry_run rm -rf "$KARABINER.bck"
    [ -d "$KARABINER" ] && dry_run mv $KARABINER "$KARABINER.bck"
    echo "$LOG_PREFIX Linking karabiner again"
    dry_run stow -d $source -t $target $STOW_FLAGS "karabiner"
    debug "Checking (again) if karabiner folder (not file) was linked"
    [ -L $KARABINER ] && return
    dry_run echo "$LOG_PREFIX WARN: Failed to link karabiner folder"
}

post_ssh(){
    debug "post_ssh"
    [ "$IS_DELINKING" == "true" ] && return
    local ssh_cmd="Include '$HOME/.ssh/config.personal'"
    echo "$LOG_PREFIX INFO: Include the ssh configurations in ~/.ssh/config:"
    echo "$LOG_PREFIX $ssh_cmd"
}

# ------------------------------------------------------------------------------

if ! command -v "stow" &> /dev/null; then
    echo "ERROR: Command 'stow' is not available. Install and try again?" 1>&2
    exit 9
fi

# ==============================================================================


parse_common_args

source="$DOTFILES/_packages"
target="$XDG_CONFIG_HOME"
apps=( $( ls "$source" ) )

start_log_group "Linking (stowing) ${#apps[@]} apps: ${apps[@]}"

stow_flags=""
IS_DELINKING=false
for arg in ${ARGS[@]}; do
    case $arg in
        -S|--stow) stow_flags="-S $stow_flags" ;;
        -R|--restow) stow_flags="-R $stow_flags" ;;
        -D|--delete) 
            stow_flags="-D $stow_flags" 
            IS_DELINKING=true
            ;;
    esac
done


num_apps="${#apps[@]}"
debug "num_apps = $num_apps"
i=1
for app in "${apps[@]}"; do
    printf -v log_group_for "[%2d/%2d] %s" $i $num_apps $app
    start_log_group "$log_group_for"

    run_app_hook "$app" "pre"

    dry_run stow -d "$source" -t "$target" $stow_flags "$app"

    run_app_hook "$app" "post"
    end_log_group
    ((i++))
done
