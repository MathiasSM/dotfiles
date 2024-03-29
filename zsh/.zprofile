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

# Set the list of directories that Zsh searches for programs.
# path=(
#   $HOME/{,s}bin(N)
#   /opt/{homebrew,local}/{,s}bin(N)
#   /usr/local/{,s}bin(N)
#   $path
# )

