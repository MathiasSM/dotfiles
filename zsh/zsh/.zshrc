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

# Set a good term for interactivity
export TERM=xterm-256color
[ -n "$TMUX" ] && export TERM=tmux-256color

# Some zsh options (most others I like are set by zprezto)
setopt CHASE_LINKS       # Resolves symlinks on cd and expanding
setopt APPEND_CREATE     # Do not yell when a file doesn't exist at append
setopt C_PRECEDENCES     # For arithmetics!

# Custom completions (before zprezto compiles them)
if type brew &>/dev/null; then
  fpath=("$(brew --prefix)/share/zsh/site-functions" $fpath)
  fpath=("$(brew --prefix)/share/zsh-completions" $fpath)
fi

# Load Prezto
source "$ZDOTDIR/zprezto/init.zsh" # This loads .zpreztorc

export PROMPT='%F{gray}%* %f'$PROMPT
export PROMPT='%F{$prompt_pure_colors[suspended_jobs]}%(1j.[%j] .)%f'$PROMPT

# Prompt: Show red exit code on right, with timestamp
precmd_pipestatus() {
  local cmd_pipestatus=($pipestatus) # First line!
  local display_timestamp='%F{white}[%*]'
  RPROMPT=$display_timestamp 
  if [[ "${cmd_pipestatus[-1]}" != 0 ]]; then
      local display_code="%F{\$prompt_pure_colors[prompt:error]}[${(j:|:)cmd_pipestatus}]%f"
    export RPROMPT=$display_code' '$RPROMPT
  fi
  export RPROMPT='%F{gray}# '$RPROMPT'%f'
}
add-zsh-hook precmd precmd_pipestatus

# Add any extra file
for f in $ZDOTDIR/.zshrc.d/*; do
   . "$f"
done

