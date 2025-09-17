#!/usr/bin/env sh

# =============================================================================
# To be sourced from .profile ONLY
# =============================================================================

# Editors
export LANG='en_US.UTF-8'
if command -v nvim > /dev/null; then
    export EDITOR='nvim'
    export VISUAL='nvim'
else
    echo "NeoVim ('nvim') not present, using vim as EDITOR" 1>&2
    export EDITOR='vim'
    export VISUAL='vim'
fi

# Open (externally)
if [ "$OS" = "macos" ]; then
    export BROWSER='open'
else
    export BROWSER='xdg-open';
fi

# Pagers
export PAGER='less'
export LESS='-g -i -M -R -F -S -w -X -z-4'

# `time` builtin
if [ "$USING_SHELL" = "zsh" ]; then
    eval "export TIMEFMT=$'-\n%J\nuser\t%U\nsystem\t%S\nreal\t%E\ncpu\t%P\nmem\t%MK'"
fi
# ls -l (at least): YYYY-MM-DD
export TIME_STYLE="+%Y-%m-%d"

