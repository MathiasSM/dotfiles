#!/usr/bin/env sh

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
# =============================================================================
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
# Docker 
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
# Elinks
export ELINKS_CONFDIR="$XDG_CONFIG_HOME/elinks"
# Gems (Ruby)
export GEM_HOME="$XDG_DATA_HOME/gem"
export GEM_SPEC_CACHE="$XDG_CACHE_HOME/gem"
# Go
export GOPATH="$XDG_DATA_HOME/go"
# Haskell
export GHCUP_USE_XDG_DIRS=true
# GnuPG (Careful if changing default)
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
# Gradle
export GRADLE_USER_HOME="$XDG_DATA_HOME/gradle"
# Less
export LESSHISTFILE="$XDG_STATE_HOME/less/history"
# Terminfo
export TERMINFO_DIRS="$XDG_DATA_HOME/terminfo:/usr/share/terminfo"
# Node REPL
export NODE_REPL_HISTORY="$XDG_DATA_HOME/node_repl_history"
# Nodenv (Node)
export NODENV_ROOT="$XDG_DATA_HOME/nodenv"
# Npm
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"
export NPM_CONFIG_TMP="$XDG_RUNTIME_DIR/npm"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export NPM_CONFIG_INIT_MODULE="$XDG_CONFIG_HOME/npm/config/npm-init.js"
# Nvm
export NVM_DIR="$XDG_DATA_HOME/nvm"
# Plenv (Perl)
export PLENV_ROOT="$XDG_DATA_HOME/plenv"
# Python
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonrc.py"
touch -a "$XDG_STATE_HOME/python_history"
# Pyenv (Python)
export PYENV_ROOT="$XDG_DATA_HOME/pyenv"
# Rustup (Rust)
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
# Stack (Haskell)
export STACK_XDG=true
# Wget
#alias wget=wget --hsts-file="$XDG_DATA_HOME/wget-hsts"
command -v wget > /dev/null && wget() {
    command wget --hsts-file="$XDG_DATA_HOME/wget-hsts"
}
export WGETRC="$XDG_CONFIG_HOME/wgetrc"
# X
export ICEAUTHORITY="$XDG_CACHE_HOME/ICEauthority"
export ERRFILE="$XDG_CACHE_HOME/X11/xsession-errors"
# Zsh
[[ -d "$XDG_STATE_HOME/zsh" ]] || mkdir -p "$XDG_STATE_HOME/zsh"
export HISTFILE="$XDG_STATE_HOME/zsh/history"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"



# Platform specific
# =============================================================================
# macOS-only additions (mostly homebrew's <something>)
if [ "$OS" = "macos" ]; then
    # Mimic the result of the slow path_helper (and be explicit)
    # NOTE: Remove path_helper call from /etc/zprofile
    mimic_path_helper() {
        local codex="/var/run/com.apple.security.cryptexd/codex.system"
        PATH="/usr/local/bin" # RESETS!
        PATH="$PATH:/System/Cryptexes/App/usr/bin"
        PATH="$PATH:/usr/bin"
        PATH="$PATH:/bin"
        PATH="$PATH:/usr/sbin"
        PATH="$PATH:/sbin"
        PATH="$PATH:$codex/bootstrap/usr/local/bin"
        PATH="$PATH:$codex/bootstrap/usr/bin"
        PATH="$PATH:$codex/bootstrap/usr/appleinternal/bin"
        PATH="$PATH:/Library/Apple/usr/bin"
        PATH="$PATH:/usr/local/MacGPG2/bin" # Only needed if present... oh well
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
# Install  nvim, nodenv, pyenv, plenv, rbenv, tree-sitter

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

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Perl
export PATH="$PLENV_ROOT/bin:$PATH"
if which plenv > /dev/null; then eval "$(plenv init - zsh)"
else echo "Missing 'plenv', skipping its config"; fi

# GHCUP (Haskell; cabal etc)
[ -f "$XDG_DATA_HOME/ghcup/env" ] && . "$XDG_DATA_HOME/ghcup/env" # ghcup-env
export PATH="$XDG_CONFIG_HOME/cabal/bin:$PATH"

# Cargo
if which cargo > /dev/null; then source "$XDG_DATA_HOME/cargo/env"; fi


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

command -v df >/dev/null && df() {
    command df --exclude-type=tmpfs --exclude-type=devtmpfs -h --print-type "$@"
}

# (git)hub
command -v hub >/dev/null && eval "$(hub alias -s)"

