#!/usr/bin/env zsh

# =============================================================================
#   file                   | +l+i | +l-i | -l+i | -l-i | note
# - /etc/zshenv            | true | true | true | true |
# - $ZDOTDIR/.zshenv       | true | true | true | true |
# - /etc/zprofile          | true | true |      |      | macos path_helper
# - $ZDOTDIR/.zprofile     | true | true |      |      |
# > /etc/zshrc             | true |      | true |      |
# - $ZDOTDIR/.zshrc        | true |      | true |      |
# - /etc/zlogin            | true | true |      |      |
# - $ZDOTDIR/.zlogin       | true | true |      |      |
# - /etc/zlogout           | true | true |      |      | on exit
# - $ZDOTDIR/.zlogout      | true | true |      |      | on exit
# =============================================================================
#
# This file shall include anything regarding interactive sessions
#
# - TERM
# - tmux
# - (auto) completion scripts
# - Prompt setup
# - ?
#
# -----------------------------------------------------------------------------

# Uncomment this and zprof at the end, to measure load times
# zmodload zsh/zprof

for f in $ZDOTDIR/.zshrc.d/*; do
   . "$f"
done

# zprof
