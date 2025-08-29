#!/usr/bin/env zsh

# =============================================================================
#   file                   | +l+i | +l-i | -l+i | -l-i | note
# - /etc/zshenv            | true | true | true | true |
# - $ZDOTDIR/.zshenv       | true | true | true | true |
# - /etc/zprofile          | true | true |      |      | macos path_helper
# - $ZDOTDIR/.zprofile     | true | true |      |      |
# - /etc/zshrc             | true |      | true |      |
# - $ZDOTDIR/.zshrc        | true |      | true |      |
# - /etc/zlogin            | true | true |      |      |
# - $ZDOTDIR/.zlogin       | true | true |      |      |
# - /etc/zlogout           | true | true |      |      | on exit
# > $ZDOTDIR/.zlogout      | true | true |      |      | on exit
# =============================================================================
#
# This file only gets called in login sessions.
#
# Keep it in sync with zlogin, to clean up any resources created there
#
# - processes started in the background
#
# -----------------------------------------------------------------------------


# Kill the session's ssh agent
ssh-agent -k >/dev/null
