#!/usr/bin/env zsh

# =============================================================================
# In order (always /etc/<file> before each):
#
# - $ZDOTDIR/.zshenv
# - $ZDOTDIR/.zprofile  (if login shell)
# - $ZDOTDIR/.zshrc     (if interactive)
# - $ZDOTDIR/.zpreztorc (zprezto)
# > $ZDOTDIR/.zlogin    (if login shell)
# - $ZDOTDIR/.zlogout   (if exiting a login shell)
# =============================================================================

# Execute code that does not affect the current session in the background.
{
  # Compile the completion dump to increase startup speed.
  zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/prezto/zcompdump"
  if [[ -s "$zcompdump" && (! -s "${zcompdump}.zwc" || "$zcompdump" -nt "${zcompdump}.zwc") ]]; then
    if command mkdir "${zcompdump}.zwc.lock" 2>/dev/null; then
      zcompile "$zcompdump"
      command rmdir  "${zcompdump}.zwc.lock" 2>/dev/null
    fi
  fi
} &!

# Execute code only if STDERR is bound to a TTY.
if [[ -o INTERACTIVE && -t 2 ]]; then

  # Print a random, hopefully interesting, adage.
  if (( $+commands[fortune] )); then
    fortune -s
    print
  fi

fi >&2

