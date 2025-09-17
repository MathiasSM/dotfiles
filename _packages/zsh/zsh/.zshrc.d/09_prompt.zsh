#!/usr/bin/env zsh


# Completions setup
# -----------------------------------------------------------------------------
if type brew &>/dev/null; then
  fpath+=("$(brew --prefix)/share/zsh-completions" $fpath)
fi
# Zprezto completions module handles the rest


# Zprezto
# -----------------------------------------------------------------------------
source "$ZDOTDIR/zprezto/init.zsh" # This loads .zpreztorc


# Prompt (Mostly configured by zprezto's pure theme)
# -----------------------------------------------------------------------------

export PROMPT='%F{gray}%* %f'$PROMPT
export PROMPT='%F{$prompt_pure_colors[suspended_jobs]}%(1j.[%j] .)%f'$PROMPT
export RPROMPT=''
