#!/usr/bin/env zsh

# ls
# -----------------------------------------------------------------------------
eval "$(dircolors -b)" # Setup LS_COLORS
alias ls="${aliases[ls]:-ls} --color=auto"

# grep
# -----------------------------------------------------------------------------
export GREP_COLORS=${GREP_COLORS:-"mt=$GREP_COLOR"}
alias grep="${aliases[grep]:-grep} --color=auto"

# Less
# -----------------------------------------------------------------------------

export LESS_TERMCAP_mb=$'\E[01;31m'       # Begins blinking.
export LESS_TERMCAP_md=$'\E[01;31m'       # Begins bold.
export LESS_TERMCAP_me=$'\E[0m'           # Ends mode.
export LESS_TERMCAP_se=$'\E[0m'           # Ends standout-mode.
export LESS_TERMCAP_so=$'\E[00;47;30m'    # Begins standout-mode.
export LESS_TERMCAP_ue=$'\E[0m'           # Ends underline.
export LESS_TERMCAP_us=$'\E[01;32m'       # Begins underline.

# Ant (Java)
# -----------------------------------------------------------------------------
ANT_ARGS="${ANT_ARGS:-}"
ANT_ARGS+=" -logger org.apache.tools.ant.listener.AnsiColorLogger"
ANT_OPTS+=" -Dant.logger.defaults=$XDG_CONFIG_DIR/ant/AnsiColorLogger"
export ANT_OPTS

