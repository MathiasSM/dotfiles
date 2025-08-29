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
# > $ZDOTDIR/.zlogin       | true | true |      |      |
# - /etc/zlogout           | true | true |      |      | on exit
# - $ZDOTDIR/.zlogout      | true | true |      |      | on exit
# =============================================================================
#
# Keep it in sync with zlogout; remember to cleanup any resources there.
#
# - processes to start in the background
# - messages
#
# -----------------------------------------------------------------------------


# Execute code that does not affect the current session in the background.
{

  # Compile the completion dump to increase startup speed.
  zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/prezto/zcompdump"
  if [[ -s "$zcompdump" \
    && (! -s "${zcompdump}.zwc" \
        || "$zcompdump" -nt "${zcompdump}.zwc") ]]; then
    if command mkdir "${zcompdump}.zwc.lock" 2>/dev/null; then
      zcompile "$zcompdump"
      command rmdir  "${zcompdump}.zwc.lock" 2>/dev/null
    fi
  fi

} &!


# Start ssh-agent if not running
ssh_agent_env_file="$XDG_CACHE_HOME/ssh-agent.env"
ssh_agent_lifetime=1h
if ! pgrep -u "$USER" ssh-agent >/dev/null; then
    ssh-agent -s -t "$ssh_agent_lifetime" > "$ssh_agent_env_file"
fi
if [[ ! "$SSH_AUTH_SOCK" ]]; then
    source "$ssh_agent_env_file" >/dev/null
fi


# Execute code only if STDERR is bound to a TTY.
if [[ -o INTERACTIVE && -t 2 ]]; then

  # Print a random, hopefully interesting, adage.
  if (( $+commands[fortune] )); then
    fortune -s
    print
  fi

fi >&2

