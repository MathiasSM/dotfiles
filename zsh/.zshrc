#!/usr/bin/env zsh

# =============================================================================
# In order (always /etc/<file> before each):
#
# - $ZDOTDIR/.zshenv
# - $ZDOTDIR/.zprofile  (if login shell)
# > $ZDOTDIR/.zshrc     (if interactive)
# - $ZDOTDIR/.zpreztorc (zprezto)
# - $ZDOTDIR/.zlogin    (if login shell)
# - $ZDOTDIR/.zlogout   (if exiting a login shell)
# =============================================================================


# Set a good term
export TERM=xterm-256color
[ -n "$TMUX" ] && export TERM=tmux-256color

# Remove tmpfs from df
function df() {
  df --exclude-type=tmpfs --exclude-type=devtmpfs -h --print-type "$@"
}

# Print the file pointed by the symlink
unalias catlink 2>/dev/null
function catlink(){ ls -l "$1" | cut -d ' ' -f 11 }

# Add some options
setopt CHASE_LINKS       # Resolves symlinks on cd and expanding
setopt APPEND_CREATE     # Do not yell when a file doesn't exist at append
setopt C_PRECEDENCES     # For arithmetics!

# Load Prezto
source "$HOME/.zprezto/init.zsh" # This loads .zpreztorc

# And custom completions
if type brew &>/dev/null; then
  fpath=("$(brew --prefix)/share/zsh/site-functions" $fpath)
  fpath=("$(brew --prefix)/share/zsh-completions" $fpath)
fi
autoload -U compinit && compinit

# (git)hub
command -v hub >/dev/null && eval `hub alias -s`

