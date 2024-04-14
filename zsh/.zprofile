#!/usr/bin/env zsh

# =============================================================================
# In order (always /etc/<file> before each):
#
# - $ZDOTDIR/.zshenv
# > $ZDOTDIR/.zprofile  (if login shell)
# - $ZDOTDIR/.zshrc     (if interactive)
# - $ZDOTDIR/.zpreztorc (zprezto)
# - $ZDOTDIR/.zlogin    (if login shell)
# - $ZDOTDIR/.zlogout   (if exiting a login shell)
# =============================================================================

# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path
