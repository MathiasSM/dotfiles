#!/usr/bin/env zsh

export TERM=xterm-256color
[ -n "$TMUX" ] && export TERM=tmux-256color

# History
HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=100000
SAVEHIST=$HISTSIZE

