#!/usr/bin/env zsh

# =============================================================================
#   file                   | +l+i | +l-i | -l+i | -l-i | note
# - /etc/zshenv            | true | true | true | true |
# > $ZDOTDIR/.zshenv       | true | true | true | true |
# - /etc/zprofile          | true | true |      |      | macos path_helper
# - $ZDOTDIR/.zprofile     | true | true |      |      |
# - /etc/zshrc             | true |      | true |      |
# - $ZDOTDIR/.zshrc        | true |      | true |      |
# - /etc/zlogin            | true | true |      |      |
# - $ZDOTDIR/.zlogin       | true | true |      |      |
# - /etc/zlogout           | true | true |      |      | on exit
# - $ZDOTDIR/.zlogout      | true | true |      |      | on exit
# =============================================================================
#
# This file shall include as most env variables as possible
# Taking into account PATH is not yet ready
#
# ONLY environment variables, please
#
# -----------------------------------------------------------------------------


# Uncomment for debugging purposes only
# setopt SOURCE_TRACE
# setopt XTRACE

# Load env
source "$HOME/.env/shellenv"
source "$HOME/.env/dotfiles"

# Set ZDOTDIR
[ -d "$XDG_STATE_HOME/zsh" ] || mkdir -p "$XDG_STATE_HOME/zsh"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# Source .zprofile if non-login, because I still want it sourced
if [[ ! -o LOGIN ]]; then
  [ -s "/etc/zprofile" ] && source "/etc/zprofile"
  [ -s "$ZDOTDIR/.zprofile" ] && source "$ZDOTDIR/.zprofile"
fi
