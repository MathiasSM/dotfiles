#!/usr/bin/env zsh

# =============================================================================
# In order (always /etc/<file> before each):
#
# > $ZDOTDIR/.zshenv
# - $ZDOTDIR/.zprofile  (if login shell)
# - $ZDOTDIR/.zshrc     (if interactive)
# - $ZDOTDIR/.zpreztorc (zprezto)
# - $ZDOTDIR/.zlogin    (if login shell)
# - $ZDOTDIR/.zlogout   (if exiting a login shell)
# =============================================================================

# Setup
# =============================================================================
# Get the OS shortname for future reference
case "`uname -s`" in
    Linux*)     export OS=linux;;
    Darwin*)    export OS=macos;;
    CYGWIN*)    export OS=windows;;
    MINGW*)     export OS=windows;;
    *)          export OS="${unameOut}"
esac



# XDG
# ==============================================================================
# XDG folders
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

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
alias wget=wget --hsts-file="$XDG_DATA_HOME/wget-hsts"
# Zsh
export HISTFILE="$XDG_STATE_HOME/zsh/history"



# Platform specific
# =============================================================================
# macOS-only additions (mostly homebrew's <something>)
if [ $OS = "macos" ]; then
    # Mimic the result of the slow path_helper (and be explicit)
    # NOTE: Remove path_helper call from /etc/zprofile
    path=(
        "/usr/local/bin"
        "/System/Cryptexes/App/usr/bin"
        "/usr/bin"
        "/bin"
        "/usr/sbin"
        "/sbin"
        "/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin"
        "/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin"
        "/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin"
        "/Library/Apple/usr/bin"
        "/usr/local/MacGPG2/bin" # Only needed if present but oh well
    )
    manpaths=(
        "/usr/share/man"
        "/usr/local/share/man"
        "/usr/local/MacGPG2/share/man"
    )
    # Put brew paths
    eval $(/usr/local/bin/brew shellenv)
    # gnu-utils manual pages (binaries handled by zprezto)
    export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
    # Link homebrew's Postgres
    export PATH="/usr/local/opt/postgresql@16/bin:$PATH"
fi



# Shell configuration
# =============================================================================
# Personal PATH
export PATH="$HOME/.local/bin:$PATH"

# Editors
export LANG='en_US.UTF-8'
if which nvim > /dev/null; then
    export EDITOR='nvim'
    export VISUAL='nvim'
else
    echo "NeoVim ('nvim') not present, using vim as EDITOR"
    export EDITOR='vim'
    export VISUAL='vim'
fi

# Open (externally)
# Actually, zprezto aliases `o` to the right one, but only in interactive shells
if [ $OS = "macos" ]; then export BROWSER='open'
else export BROWSER='xdg-open'; fi

# Pager
export PAGER='less'
export LESS='-g -i -M -R -F -S -w -X -z-4'

# `time` builtin
export TIMEFMT=$'-\n%J\nuser\t%U\nsystem\t%S\nreal\t%E\ncpu\t%P\nmem\t%MK'
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

# Perl
export PATH="$PLENV_ROOT/bin:$PATH"
if which plenv > /dev/null; then eval "$(plenv init - zsh)"
else echo "Missing 'plenv', skipping its config"; fi



# Some aliases
# ==============================================================================
alias ls="ls --color=auto"

local tab="%x09"
local a_date="%C(blue)%ad"
local s_hash="%C(yellow)(%h)"
local refs="%C(red)%d" # Try %D
local a_subject="%C(reset)%<|(100) %s"
local c_name="%C(blue) [%cn]"
export GIT_ALIAS_LOGG="$tab$a_date $s_hash$refs $a_subject$c_name"
export GIT_ALIAS_LOGGA="$tab$a_date $s_hash$refs $a_subject$c_name"
export GIT_ALIAS_LOGGA_GPG="$tab$a_date $s_hash$refs $a_subject$c_name %G? %GK"

# (git)hub
command -v hub >/dev/null && eval `hub alias -s`

# # Remove tmpfs from df (annoying in macOS)
function df() {
  df --exclude-type=tmpfs --exclude-type=devtmpfs -h --print-type "$@"
}


# Finally...
# =============================================================================
# Ensure that a non-login, non-interactive shell has a defined environment.
if [[ ( "$SHLVL" -eq 1 && ! -o LOGIN ) && -s "$HOME/.zprofile" ]]; then
  source "$HOME/.zprofile"
fi
