#!/usr/bin/env zsh

# =============================================================================
#   file                   | +l+i | +l-i | -l+i | -l-i | note
# - /etc/zshenv            | true | true | true | true |
# - $ZDOTDIR/.zshenv       | true | true | true | true |
# - /etc/zprofile          | true | true |      |      | macos path_helper
# > $ZDOTDIR/.zprofile     | true | true |      |      |
# - /etc/zshrc             | true |      | true |      |
# - $ZDOTDIR/.zshrc        | true |      | true |      |
# - /etc/zlogin            | true | true |      |      |
# - $ZDOTDIR/.zlogin       | true | true |      |      |
# - /etc/zlogout           | true | true |      |      | on exit
# - $ZDOTDIR/.zlogout      | true | true |      |      | on exit
# =============================================================================
#
# This file shall be simply an alias to ~/.profile, to keep settings shared
#
# If there's anything specific for login shells, specific for zsh, add it here
#
# -----------------------------------------------------------------------------

. "$HOME/.profile" # Single file for bash+zsh

# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path
