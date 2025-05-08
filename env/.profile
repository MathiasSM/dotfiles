#!/usr/bin/env sh
# shellcheck shell=dash

# =============================================================================
# To be sourced first from .zshenv or any relevant script
# =============================================================================

# Setup
# =============================================================================
# Get the OS shortname for future reference
OS="$(uname -s)"
case "$OS" in
    Linux*)     export OS=linux;;
    Darwin*)    export OS=macos;;
    CYGWIN*)    export OS=windows;;
    MINGW*)     export OS=windows;;
esac

# Get the SHELL shortname for future reference
case "$SHELL" in
    *zsh)   export USING_SHELL=zsh;;
    *bash)  export USING_SHELL=bash;;
    *dash)  export USING_SHELL=dash;;
    *)      export USING_SHELL="$SHELL";;
esac



# XDG
# ==============================================================================
# XDG folders
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"
export PERSONAL_BINARIES_HOME="$HOME/.local/bin"

# Android
export ANDROID_USER_HOME="$XDG_DATA_HOME/android"
# AWS
export AWS_SHARED_CREDENTIALS_FILE="$XDG_CONFIG_HOME/aws/credentials"
export AWS_CONFIG_FILE="$XDG_CONFIG_HOME/aws/config"
# Cargo (Rust)
export CARGO_HOME="$XDG_DATA_HOME/cargo"
# Gems (Ruby)
export GEM_HOME="$XDG_DATA_HOME/gem"
export GEM_SPEC_CACHE="$XDG_CACHE_HOME/gem"
# Haskell
export GHCUP_USE_XDG_DIRS=true
# GnuPG (Careful if changing default)
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
# Less
export LESSHISTFILE="$XDG_STATE_HOME/less/history"
# Terminfo
export TERMINFO_DIRS="$XDG_DATA_HOME/terminfo:/usr/share/terminfo"
# Node REPL
export NODE_REPL_HISTORY="$XDG_DATA_HOME/node_repl_history"
# Nodenv (Node)
export NODENV_ROOT="$XDG_DATA_HOME/nodenv"
# Npm
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
# Plenv (Perl)
export PLENV_ROOT="$XDG_DATA_HOME/plenv"
# Python
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonrc.py"
touch -a "$XDG_STATE_HOME/python_history"
# Pyenv (Python)
export PYENV_ROOT="$XDG_DATA_HOME/pyenv"
# Stack (Haskell)
export STACK_XDG=true
# Wget
command -v wget > /dev/null && wget() {
    command wget --hsts-file="$XDG_DATA_HOME/wget-hsts"
}
export WGETRC="$XDG_CONFIG_HOME/wgetrc"
# X
export ICEAUTHORITY="$XDG_CACHE_HOME/ICEauthority"
export ERRFILE="$XDG_CACHE_HOME/X11/xsession-errors"
# Zsh
export HISTFILE="$XDG_STATE_HOME/zsh/history"



# Platform specific
# =============================================================================
# macOS-only additions (mostly homebrew's <something>)
if [ "$OS" = "macos" ]; then
    # Mimic the result of the slow path_helper (and be explicit)
    # NOTE: Remove path_helper call from /etc/zprofile
    mimic_path_helper() {
        PATH="/usr/local/bin" # RESETS!
        PATH="$PATH:/System/Cryptexes/App/usr/bin"
        PATH="$PATH:/usr/bin"
        PATH="$PATH:/bin"
        PATH="$PATH:/usr/sbin"
        PATH="$PATH:/sbin"
        PATH="$PATH:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin"
        PATH="$PATH:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin"
        PATH="$PATH:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin"
        PATH="$PATH:/Library/Apple/usr/bin"
        PATH="$PATH:/usr/local/MacGPG2/bin" # Only needed if present but oh well
        export PATH
        MANPATH="/usr/share/man" # RESETS!
        MANPATH="$MANPATH:/usr/local/share/man"
        MANPATH="$MANPATH:/usr/local/MacGPG2/share/man" # Only needed if present but oh well
        export MANPATH
    }
    mimic_path_helper
    # Put brew paths
    eval "$(/usr/local/bin/brew shellenv)"
    # gnu-utils manual pages (binaries handled by zprezto)
    export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
    # Link homebrew's Postgres
    export PATH="/usr/local/opt/postgresql@16/bin:$PATH"
fi



# Shell configuration
# =============================================================================
# Personal PATH and /opt-installed binaries
export PATH="$PERSONAL_BINARIES_HOME:$PATH"
export PATH="/opt/nvim/bin:$PATH"
export PATH="/opt/nodenv/bin:$PATH"
export PATH="/opt/pyenv/bin:$PATH"
export PATH="/opt/plenv/bin:$PATH"
export PATH="/opt/rbenv/bin:$PATH"
export PATH="/opt/tree-sitter/bin:$PATH"

# Editors
export LANG='en_US.UTF-8'
if command -v nvim > /dev/null; then
    export EDITOR='nvim'
    export VISUAL='nvim'
else
    echo "NeoVim ('nvim') not present, using vim as EDITOR"
    export EDITOR='vim'
    export VISUAL='vim'
fi

# Open (externally)
# Actually, zprezto aliases `o` to the right one, but only in interactive shells
if [ "$OS" = "macos" ]; then export BROWSER='open'
else export BROWSER='xdg-open'; fi

# Pager
export PAGER='less'
export LESS='-g -i -M -R -F -S -w -X -z-4'

if [ "$(basename "$SHELL")" = "zsh" ]; then
    # `time` builtin
    eval "export TIMEFMT=$'-\n%J\nuser\t%U\nsystem\t%S\nreal\t%E\ncpu\t%P\nmem\t%MK'"
fi
# ls -l (at least): YYYY-MM-DD
export TIME_STYLE="+%Y-%m-%d"



# Languages and environments
# =============================================================================
# Python
export PATH="$PYENV_ROOT/bin:$PATH"
if which pyenv > /dev/null; then
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
else
  echo "Missing 'pyenv', skipping its config"
fi

# Node
export PATH="$NODENV_ROOT/bin:$PATH"
if which nodenv > /dev/null; then eval "$(nodenv init -)"
else echo "Missing 'nodenv', skipping its config"; fi

# Ruby
export PATH="$RUBYENV_ROOT/bin:$PATH"
if which rbenv > /dev/null; then eval "$(rbenv init -)"
else echo "Missing 'rbenv', skipping its config"; fi

# Perl
export PATH="$PLENV_ROOT/bin:$PATH"
if which plenv > /dev/null; then eval "$(plenv init - zsh)"
else echo "Missing 'plenv', skipping its config"; fi

# GHCUP (Haskell; cabal etc)
[ -f "$XDG_DATA_HOME/ghcup/env" ] && . "$XDG_DATA_HOME/ghcup/env" # ghcup-env
export PATH="$XDG_CONFIG_HOME/cabal/bin:$PATH"


# Some aliases
# ==============================================================================
alias ls="ls --color=auto"

set_git_aliases() {
    local tab="%x09"
    local a_date="%C(blue)%ad"
    local s_hash="%C(yellow)(%h)"
    local refs="%C(red)%d" # Try %D
    local a_subject="%C(reset)%<|(100) %s"
    local c_name="%C(blue) [%cn]"
    export GIT_ALIAS_LOGG="$tab$a_date $s_hash$refs $a_subject$c_name"
    export GIT_ALIAS_LOGGA="$tab$a_date $s_hash$refs $a_subject$c_name"
    export GIT_ALIAS_LOGGA_GPG="$tab$a_date $s_hash$refs $a_subject$c_name %G? %GK"
}
set_git_aliases

# (git)hub
command -v hub >/dev/null && eval "$(hub alias -s)"

